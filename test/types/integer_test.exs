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

  describe "Bliss.Integer.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Integer.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("123")
        |> Integer.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not an integer",
               path: ["."]
             })
    end

    test "given empty options, when integer value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Integer.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when float value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(34.5)
        |> Integer.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not an integer",
               path: ["."]
             })
    end
  end

  describe "Bliss.Integer.check(_, :min, _, _)/4" do
    test "given min value, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(5)
        |> Integer.check(:min, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too small",
               path: ["."]
             })
    end

    test "given min value, when great enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11)
        |> Integer.check(:min, 11, Context.new("."))

      assert result.status == :valid
    end
  end
end
