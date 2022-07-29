defmodule Z.Struct do
  @moduledoc """
  A module for defining Z structs
  """

  defmacro __using__(_) do
    quote do
      import Z.Struct, only: [schema: 1]

      Module.register_attribute(__MODULE__, :z_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :z_enforced_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :z_struct_fields, accumulate: true)
    end
  end

  defmacro schema(do: block) do
    __schema__(__CALLER__, block)
  end

  defp __schema__(caller, block) do
    quote do
      unquote(define_schema(caller, block))
      unquote(define_struct())
    end
  end

  defp define_schema(caller, block) do
    quote do
      if line = Module.get_attribute(__MODULE__, :z_schema_defined) do
        raise "schema already defined for #{inspect(__MODULE__)} on line #{line}"
      end

      @z_schema_defined unquote(caller.line)

      try do
        import Z.Struct, only: [field: 2, field: 3]
        unquote(block)
      after
        :ok
      end
    end
  end

  defp define_struct() do
    quote unquote: false do
      fields = Macro.escape(@z_fields) |> Enum.reverse()

      @enforce_keys Enum.reverse(@z_enforced_fields)
      defstruct Enum.reverse(@z_struct_fields)

      use Z.Type, options: unquote(Z.Any.__z__(:options) ++ [:cast])

      def __z__(:fields), do: unquote(fields)

      def new(enum \\ []) do
        struct(__MODULE__, enum)
        |> validate()
      end

      def new!(enum \\ []) do
        case new(enum) do
          {:ok, value} -> value
          {:error, error} -> raise error
        end
      end

      def check(result, :conversions, rules, context) do
        result
        |> Z.Any.check(:conversions, rules, context)
        |> maybe_check(:cast, rules, context)
      end

      def check(result, :mutations, rules, context) do
        result
        |> Z.Any.check(:mutations, rules, context)
      end

      def check(result, :assertions, rules, context) do
        result
        |> Z.Any.check(:assertions, rules, context)
        |> check(:fields, rules, context)
      end

      def check(result, rule, options, context) do
        Z.Struct.__check__(result, rule, options, context)
      end
    end
  end

  def __check__(result, rule, options, context) do
    check(result, rule, options, context)
  end

  defp check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  defp check(result, :cast, _enabled, _context) when not is_map(result.value) do
    result
  end

  defp check(result, :cast, _enabled, context) when is_struct(result.value, context.type) do
    result
  end

  defp check(result, :cast, false, _context) do
    result
  end

  defp check(result, :cast, true, context) when is_struct(result.value) do
    result
    |> Z.Result.set_value(struct(context.type, Map.from_struct(result.value)))
  end

  defp check(result, :cast, true, context) do
    result
    |> Z.Result.set_value(struct(context.type, result.value))
  end

  defp check(result, :type, options, context) when not is_struct(result.value, context.type) do
    message = Keyword.get(options, :message, "input is not a #{inspect(context.type)}")

    result
    |> Z.Result.add_issue(
      Z.Issue.new(
        Z.Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  defp check(result, :type, _options, _context) do
    result
  end

  defp check(result, _rule, _options, context)
       when not is_struct(result.value, context.type) do
    result
  end

  defp check(result, :fields, _options, context) do
    Enum.reduce(context.type.__z__(:fields), result, fn {name, {type, rules}}, res ->
      check_field(res, name, type, rules, context)
    end)
  end

  defp check_field(result, name, type, rules, context) do
    case type.validate(Map.get(result.value, name), rules, Z.Context.new(type, name, context)) do
      {:ok, value} ->
        result |> Z.Result.set_value(Map.replace(result.value, name, value))

      {:error, error} ->
        result |> Z.Result.add_issues(error.issues)
    end
  end

  defmacro field(name, type, rules \\ []) do
    quote do
      Z.Struct.__field__(__MODULE__, unquote(name), unquote(type), unquote(rules))
    end
  end

  def __field__(mod, name, type, rules) do
    rules = Z.Rule.to_keyword_list(rules)
    type = check_field_type!(name, type)
    check_rules!(name, type, rules)
    validate_default!(name, type, rules)
    define_field(mod, name, type, rules)
  end

  defp check_field_type!(name, type) do
    case Z.Type.resolve(type) do
      {:ok, type} ->
        type

      _ ->
        raise ArgumentError, "invalid type #{inspect(type)} for field #{inspect(name)}"
    end
  end

  defp check_rules!(name, type, rules) do
    case Enum.find(rules, fn {rule, _} -> rule not in type.__z__(:options) end) do
      nil ->
        :ok

      {rule, _} ->
        raise ArgumentError,
              "invalid rule #{inspect(rule)} for field #{name}"
    end
  end

  defp validate_default!(name, type, rules) do
    if Keyword.has_key?(rules, :default) do
      value = Keyword.fetch!(rules, :default)

      if !is_function(value, 0) do
        case type.validate(value, Keyword.delete(rules, :default)) do
          {:ok, _} ->
            :ok

          _ ->
            raise ArgumentError,
                  "default value #{inspect(value)} is invalid for type #{inspect(type)} of field #{inspect(name)}"
        end
      end
    end
  end

  defp define_field(mod, name, type, rules) do
    put_struct_field(mod, name, Keyword.get(rules, :default))
    put_enforced_field(mod, name, Keyword.get(rules, :required))
    Module.put_attribute(mod, :z_fields, {name, {type, rules}})
  end

  defp put_struct_field(mod, name, default) do
    fields = Module.get_attribute(mod, :z_struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError,
            "field #{inspect(name)} already exists on schema, you must either remove the duplication or choose a different name"
    end

    if is_function(default, 0) do
      Module.put_attribute(mod, :z_struct_fields, {name, nil})
    else
      Module.put_attribute(mod, :z_struct_fields, {name, default})
    end
  end

  defp put_enforced_field(mod, name, options) when is_list(options) do
    if options[:enforced] != false do
      put_enforced_field(mod, name, true)
    end
  end

  defp put_enforced_field(mod, name, true) do
    fields = Module.get_attribute(mod, :z_enforced_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError,
            "field #{inspect(name)} already exists on schema, you must either remove the duplication or choose a different name"
    end

    Module.put_attribute(mod, :z_enforced_fields, name)
  end

  defp put_enforced_field(_mod, _name, _options) do
  end
end
