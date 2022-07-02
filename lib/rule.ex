defmodule Bliss.Rule do
  @type t :: atom | Keyword.t()

  def has_rule?(list, name) when is_list(list) and is_atom(name) do
    Keyword.has_key?(list, name) || Enum.member?(list, name)
  end

  def fetch(list, name) when is_list(list) and is_atom(name) do
    if has_rule?(list, name) do
      {:ok, Keyword.get(list, name)}
    else
      :error
    end
  end

  def fetch!(list, name) when is_list(list) and is_atom(name) do
    case fetch(list, name) do
      {:ok, value} -> value
      :error -> raise KeyError, key: name, term: list
    end
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
