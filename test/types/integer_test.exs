defmodule Bliss.Integer.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, Integer}

  describe "Bliss.Integer.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Integer.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some integer string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("10")
        |> Integer.check(:parse, true, Context.new("."))

      assert result.value == 10
    end

    test "given `true`, when some float string, returns result with parsed integer value" do
      result =
        Result.new()
        |> Result.set_value("10.5")
        |> Integer.check(:parse, true, Context.new("."))

      assert result.value == 10
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("10")
        |> Integer.check(:parse, false, Context.new("."))

      assert result.value == "10"
    end

    test "given base 16, when some hex string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("f4")
        |> Integer.check(:parse, 16, Context.new("."))

      assert result.value == 244
    end
  end
end
