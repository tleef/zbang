defmodule Bliss.Rule do
  def has_rule?(list, name) when is_list(list) and is_atom(name) do
    Keyword.has_key?(list, name) || Enum.member?(list, name)
  end

  def delete(list, name) when is_list(list) and is_atom(name) do
    Enum.filter(list, fn rule -> rule_name(rule) != name end)
  end

  def rule_name({name, _}) do
    rule_name(name)
  end

  def rule_name(name) when is_atom(name) do
    name
  end
end
