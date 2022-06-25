defmodule Bliss.Struct do
  alias Bliss.{Type, Rule, Result}

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
        if function_exported?(type, :__type__, 0) do
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
    case Enum.find(rules, fn rule -> Rule.rule_name(rule) not in type.__options__() end) do
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
