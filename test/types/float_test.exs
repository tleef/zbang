defmodule Z.Float.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Context, Float}

  describe "Z.Float.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Float.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(10.5)
        |> Float.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some float string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("10.5")
        |> Float.check(:parse, true, Context.new("."))

      assert result.value == 10.5
    end

    test "given `true`, when some integer string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("10")
        |> Float.check(:parse, true, Context.new("."))

      assert result.value == 10.0
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("10.5")
        |> Float.check(:parse, false, Context.new("."))

      assert result.value == "10.5"
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("oops")
        |> Float.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a float",
               path: ["."]
             })
    end
  end

  describe "Z.Float.check(_, :allow_int, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Float.check(:allow_int, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(32.5)
        |> Float.check(:allow_int, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some int, returns result with converted value" do
      result =
        Result.new()
        |> Result.set_value(10)
        |> Float.check(:allow_int, true, Context.new("."))

      assert result.value == 10.0
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value(32)
        |> Float.check(:allow_int, false, Context.new("."))

      assert result.value == 32
    end
  end

  describe "Z.Float.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Float.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when float value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123.4)
        |> Float.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("123.4")
        |> Float.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a float",
               path: ["."]
             })
    end

    test "given empty options, when int value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(34)
        |> Float.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a float",
               path: ["."]
             })
    end
  end

  describe "Z.Float.check(_, :min, _, _)/4" do
    test "given min value, when not a float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(3)
        |> Float.check(:min, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given min value, when great enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11.0)
        |> Float.check(:min, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given min value, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(5.9)
        |> Float.check(:min, 6.0, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too small",
               path: ["."]
             })
    end
  end

  describe "Z.Float.check(_, :max, _, _)/4" do
    test "given max value, when not a float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(13)
        |> Float.check(:max, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given max value, when small enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11.0)
        |> Float.check(:max, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given max value, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(6.1)
        |> Float.check(:max, 6.0, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input is too big",
               path: ["."]
             })
    end
  end

  describe "Z.Float.check(_, :greater_than, _, _)/4" do
    test "given greater than value, when not a float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(8)
        |> Float.check(:greater_than, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given greater than value, when great enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(11.1)
        |> Float.check(:greater_than, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given greater than value, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(6.0)
        |> Float.check(:greater_than, 6.0, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too small",
               path: ["."]
             })
    end
  end

  describe "Z.Float.check(_, :less_than, _, _)/4" do
    test "given less than value, when not a float, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(12)
        |> Float.check(:less_than, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given less than value, when small enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(10.9)
        |> Float.check(:less_than, 11.0, Context.new("."))

      assert result.status == :valid
    end

    test "given less than value, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(6.0)
        |> Float.check(:less_than, 6.0, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input is too big",
               path: ["."]
             })
    end
  end

  describe "Z.Float.validate/3" do
    test "given some float string value, when :parse, set parsed value" do
      {:ok, 10.5} = Float.validate("10.5", [:parse])
    end

    test "given some int value, when :allow_int, set truncated value" do
      {:ok, 10.0} = Float.validate(10, [:allow_int])
    end

    test "given small value, when check :min, check min" do
      {:error, errors} = Float.validate(20.9, min: {21.0, message: "too small"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_small(),
               message: "too small",
               path: ["."]
             })
    end

    test "given large value, when check :max, check max" do
      {:error, errors} = Float.validate(17.1, max: {17.0, message: "too great"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_big(),
               message: "too great",
               path: ["."]
             })
    end

    test "given small value, when check :greater_than, check greater_than" do
      {:error, errors} = Float.validate(21.0, greater_than: {21.0, message: "not great enough"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_small(),
               message: "not great enough",
               path: ["."]
             })
    end

    test "given large value, when check :less_than, check less_than" do
      {:error, errors} = Float.validate(18.0, less_than: {18.0, message: "not small enough"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.too_big(),
               message: "not small enough",
               path: ["."]
             })
    end

    test "given some float string, when :parse and check :min & :max, parse value and check min and max" do
      {:ok, 23.0} = Float.validate("23", [:parse, min: 0.0, max: 25.0])
    end
  end
end
