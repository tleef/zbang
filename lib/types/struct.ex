defmodule Bliss.Struct do
  use Bliss.Type, options: Bliss.Any.__bliss__(:options) ++ [:cast, :unknown_keys]

  alias Bliss.{Type, Rule, Result}

  @spec __using__(opts :: [rules: [Rule.t()]]) :: any
  defmacro __using__(opts) do
    rules = Keyword.get(opts, :rules, [])

    quote do
      import Bliss.Struct, only: [schema: 1]

      use Bliss.Type, options: unquote(Bliss.Struct.__bliss__(:options))

      def __bliss__(:rules), do: unquote(rules)
      def check(result, rules, context), do: Bliss.Struct.check(result, rules, context)

      def check(result, rule, options, context),
        do: Bliss.Struct.check(result, rule, options, context)

      Module.register_attribute(__MODULE__, :bliss_fields, accumulate: true)
    end
  end

  def check(result, _options, _context) do
    result
  end

  def check(result, _, _, _) do
    result
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
          import Bliss.Struct, only: [field: 3]
          unquote(block)
        after
          :ok
        end
      end

    postlude =
      quote unquote: false do
        fields = Macro.escape(@bliss_fields) |> Enum.reverse()

        defstruct Enum.reverse(@bliss_struct_fields)

        def __bliss__(:fields), do: unquote(fields)
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
    type = check_field_type!(name, type)
    check_rule!(name, type, rules)
    validate_default!(name, type, rules)
    define_field(mod, name, type, rules)
  end

  defp check_field_type!(name, type) do
    cond do
      not is_atom(type) ->
        raise ArgumentError, "invalid type #{inspect(type)} for field #{inspect(name)}"

      Type.base?(type) ->
        Type.get(type)

      Code.ensure_compiled(type) == {:module, type} ->
        if function_exported?(type, :__bliss__, 1) do
          type
        else
          raise ArgumentError,
                "module #{inspect(type)} given as type for field #{inspect(name)} is not a Bliss.Type"
        end

      true ->
        raise ArgumentError, "unknown type #{inspect(type)} for field #{inspect(name)}"
    end
  end

  defp check_rule!(name, type, rules) do
    case Enum.find(rules, fn rule -> Rule.rule_name(rule) not in type.__bliss__(:options) end) do
      nil ->
        :ok

      rule ->
        raise ArgumentError, "invalid rule #{inspect(Rule.rule_name(rule))} for field #{name}"
    end
  end

  defp validate_default!(name, type, rules) do
    if Rule.has_rule?(rules, :default) do
      value = rules[:default]

      case apply(type, :validate, [rules[:default], Rule.delete(rules, :default)]) do
        %Result{status: :valid} ->
          :ok

        _ ->
          raise ArgumentError,
                "default value #{inspect(value)} is invalid for type #{inspect(type)} of field #{inspect(name)}"
      end
    end
  end

  defp define_field(mod, name, type, rules) do
    put_struct_field(mod, name, Keyword.get(rules, :default))
    Module.put_attribute(mod, :bliss_fields, {name, type, rules})
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
