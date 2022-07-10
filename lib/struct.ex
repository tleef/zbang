defmodule Bliss.Struct do
  defmacro __using__(_) do
    quote do
      import Bliss.Struct, only: [schema: 1]

      Module.register_attribute(__MODULE__, :bliss_fields, accumulate: true)
    end
  end

  defmacro schema(do: block) do
    __schema__(__CALLER__, block)
  end

  defp __schema__(caller, block) do
    prelude =
      quote do
        if line = Module.get_attribute(__MODULE__, :bliss_schema_defined) do
          raise "schema already defined for #{inspect(__MODULE__)} on line #{line}"
        end

        @bliss_schema_defined unquote(caller.line)

        Module.register_attribute(__MODULE__, :bliss_struct_fields, accumulate: true)

        try do
          import Bliss.Struct, only: [field: 2, field: 3]
          unquote(block)
        after
          :ok
        end
      end

    postlude =
      quote unquote: false do
        fields = Macro.escape(@bliss_fields) |> Enum.reverse()

        defstruct Enum.reverse(@bliss_struct_fields)

        use Bliss.Type, options: unquote(Bliss.Any.__bliss__(:options) ++ [:cast])

        def __bliss__(:fields), do: unquote(fields)

        def check(result, rules, context) do
          result
          |> Bliss.Any.check(rules, context)
          |> maybe_check(:cast, rules, context)
          |> check(:type, rules, context)
          |> check(:fields, rules, context)
        end

        def check(result, _rule, _options, _context) when result.value == nil do
          result
        end

        def check(result, :cast, _enabled, _context) when not is_map(result.value) do
          result
        end

        def check(result, :cast, false, _context) do
          result
        end

        def check(result, :cast, true, context) do
          result
          |> Bliss.Result.set_value(struct(__MODULE__, result.value))
        end

        def check(result, :type, options, context) when not is_struct(result.value, __MODULE__) do
          message = Keyword.get(options, :message, "input is not a #{inspect(__MODULE__)}")

          result
          |> Bliss.Result.add_error(
            Bliss.Error.new(
              Bliss.Error.Codes.invalid_type(),
              message,
              context
            )
          )
        end

        def check(result, :type, _options, _context) do
          result
        end

        def check(result, _rule, _options, _context)
            when not is_struct(result.value, __MODULE__) do
          result
        end

        def check(result, :fields, options, context) do
          Enum.reduce(__bliss__(:fields), result, fn {name, {type, rules}}, res ->
            check_field(res, name, type, rules, context)
          end)
        end

        defp check_field(result, name, type, rules, context) do
          case type.validate(Map.get(result.value, name), rules, Bliss.Context.new(name, context)) do
            {:ok, value} ->
              result |> Bliss.Result.set_value(Map.replace(result.value, name, value))

            {:error, errors} ->
              result |> Bliss.Result.add_errors(errors)
          end
        end
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  defmacro field(name, type, rules \\ []) do
    quote do
      Bliss.Struct.__field__(__MODULE__, unquote(name), unquote(type), unquote(rules))
    end
  end

  def __field__(mod, name, type, rules) do
    rules = Bliss.Rule.to_keyword_list(rules)
    type = check_field_type!(name, type)
    check_rules!(name, type, rules)
    validate_default!(name, type, rules)
    define_field(mod, name, type, rules)
  end

  defp check_field_type!(name, type) do
    case Bliss.Type.resolve(type) do
      {:ok, type} ->
        type

      _ ->
        raise ArgumentError, "invalid type #{inspect(type)} for field #{inspect(name)}"
    end
  end

  defp check_rules!(name, type, rules) do
    case Enum.find(rules, fn {rule, _} -> rule not in type.__bliss__(:options) end) do
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

      case type.validate(value, Keyword.delete(rules, :default)) do
        {:ok, _} ->
          :ok

        _ ->
          raise ArgumentError,
                "default value #{inspect(value)} is invalid for type #{inspect(type)} of field #{inspect(name)}"
      end
    end
  end

  defp define_field(mod, name, type, rules) do
    put_struct_field(mod, name, Keyword.get(rules, :default))
    Module.put_attribute(mod, :bliss_fields, {name, {type, rules}})
  end

  defp put_struct_field(mod, name, default) do
    fields = Module.get_attribute(mod, :bliss_struct_fields)

    if List.keyfind(fields, name, 0) do
      raise ArgumentError,
            "field #{inspect(name)} already exists on schema, you must either remove the duplication or choose a different name"
    end

    Module.put_attribute(mod, :bliss_struct_fields, {name, default})
  end
end
