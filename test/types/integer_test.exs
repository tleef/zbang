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

    test "given `true`, when some int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(10)
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

    test "given invalid base, when some integer string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("10")
        |> Integer.check(:parse, 42, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to parse integer with base 42, base must be in 2..36",
               path: ["."]
             })
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("oops")
        |> Integer.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as an integer",
               path: ["."]
             })
    end
  end

  describe "Bliss.Integer.check(_, :trunc, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Integer.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(10)
        |> Integer.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some float, returns result with truncated value" do
      result =
        Result.new()
        |> Result.set_value(32.5)
        |> Integer.check(:trunc, true, Context.new("."))

      assert result.value == 32
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value(32.5)
        |> Integer.check(:trunc, false, Context.new("."))

      assert result.value == 32.5
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

    test "given empty options, when integer value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
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
    test "given min value, when not an int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(3.5)
        |> Integer.check(:min, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given min value, when great enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11)
        |> Integer.check(:min, 11, Context.new("."))

      assert result.status == :valid
    end

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
  end

  describe "Bliss.Integer.check(_, :max, _, _)/4" do
    test "given max value, when not an int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(13.5)
        |> Integer.check(:max, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given max value, when small enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11)
        |> Integer.check(:max, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given max value, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(7)
        |> Integer.check(:max, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input is too big",
               path: ["."]
             })
    end
  end

  describe "Bliss.Integer.check(_, :greater_than, _, _)/4" do
    test "given greater than value, when not an int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(8.5)
        |> Integer.check(:greater_than, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given greater than value, when great enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(12)
        |> Integer.check(:greater_than, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given greater than value, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(6)
        |> Integer.check(:greater_than, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too small",
               path: ["."]
             })
    end
  end

  describe "Bliss.Integer.check(_, :less_than, _, _)/4" do
    test "given less than value, when not an int, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(12.5)
        |> Integer.check(:less_than, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given less than value, when small enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(10)
        |> Integer.check(:less_than, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given less than value, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(6)
        |> Integer.check(:less_than, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input is too big",
               path: ["."]
             })
    end
  end

  describe "Bliss.Integer.validate/3" do
    test "given some integer string value, when :parse, set parsed value" do
      {:ok, 10} = Integer.validate("10", [:parse])
    end

    test "given some float value, when :trunc, set truncated value" do
      {:ok, 10} = Integer.validate(10.5, [:trunc])
    end

    test "given small value, when check :min, check min" do
      {:error, errors} = Integer.validate(20, min: {21, message: "too small"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_small(),
               message: "too small",
               path: ["."]
             })
    end

    test "given large value, when check :max, check max" do
      {:error, errors} = Integer.validate(18, max: {17, message: "too great"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_big(),
               message: "too great",
               path: ["."]
             })
    end

    test "given small value, when check :greater_than, check greater_than" do
      {:error, errors} = Integer.validate(21, greater_than: {21, message: "not great enough"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_small(),
               message: "not great enough",
               path: ["."]
             })
    end

    test "given large value, when check :less_than, check less_than" do
      {:error, errors} = Integer.validate(18, less_than: {18, message: "not small enough"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_big(),
               message: "not small enough",
               path: ["."]
             })
    end

    test "given some float string, when :parse and check :min & :max, parse value and check min and max" do
      {:ok, 23} = Integer.validate("23.5", [:parse, min: 0, max: 25])
    end
  end
end
