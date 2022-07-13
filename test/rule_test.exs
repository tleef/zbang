defmodule Z.Rule.Test do
  use ExUnit.Case, async: true

  alias Z.Rule

  describe "Z.Rule.to_keyword_list/1" do
    test "given a list of rules, when mapping to keyword list, returns keyword list" do
      rules = [:required, default: "value", max: {8, message: "hello"}]
      rules = Rule.to_keyword_list(rules)

      assert Keyword.keyword?(rules)
      assert rules == [required: true, default: "value", max: {8, message: "hello"}]
    end
  end
end
