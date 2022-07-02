defmodule Bliss.Rule do
  @type t :: atom | Keyword.t()

  def to_keyword_list(rules) when is_list(rules) do
    Enum.map(rules, fn rule -> to_keyword(rule) end)
  end

  defp to_keyword(rule) when is_atom(rule) do
    to_keyword({rule, true})
  end

  defp to_keyword({name, _value} = rule) when is_atom(name) do
    rule
  end
end
