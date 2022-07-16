defmodule Z.Date.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Issue, Context, Date}

  describe "Z.Date.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Date.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some Date, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~D[2015-01-23])
        |> Date.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23")
        |> Date.check(:parse, true, Context.new("."))

      assert result.value == ~D[2015-01-23]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23")
        |> Date.check(:parse, false, Context.new("."))

      assert result.value == "2015-01-23"
    end

    test "given format :iso8601, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23")
        |> Date.check(:parse, :iso8601, Context.new("."))

      assert result.value == ~D[2015-01-23]
    end

    test "given invalid format, when some ISO 8601 string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23")
        |> Date.check(:parse, :invalid, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to parse Date with format: :invalid, format must be :iso8601",
               path: ["."]
             })
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-32")
        |> Date.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a Date",
               path: ["."]
             })
    end
  end

  describe "Z.Date.check(_, :trunc, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Date.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some Date, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~D[2015-01-23])
        |> Date.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some DateTime, returns result with truncated value" do
      result =
        Result.new()
        |> Result.set_value(~U[2018-07-16 10:00:00Z])
        |> Date.check(:trunc, true, Context.new("."))

      assert result.value == ~D[2018-07-16]
    end

    test "given `true`, when some NaiveDateTime, returns result with truncated value" do
      result =
        Result.new()
        |> Result.set_value(~N[2016-04-16 01:23:45])
        |> Date.check(:trunc, true, Context.new("."))

      assert result.value == ~D[2016-04-16]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value(~N[2016-04-16 01:23:45])
        |> Date.check(:trunc, false, Context.new("."))

      assert result.value == ~N[2016-04-16 01:23:45]
    end
  end

  describe "Z.Date.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Date.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when Date value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~D[2018-07-16])
        |> Date.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-Date value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Date.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a Date",
               path: ["."]
             })
    end

    test "given empty options, when NaiveDateTime value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(~N[2000-01-01 23:00:07])
        |> Date.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a Date",
               path: ["."]
             })
    end
  end

  describe "Z.Date.check(_, :min, _, _)/4" do
    test "given min Date, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Date.check(:min, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when not a Date, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Date.check(:min, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when Date late enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~D[2000-01-01])
        |> Date.check(:min, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when Date too early, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~D[1999-12-31])
        |> Date.check(:min, ~D[2000-01-01], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input is too early",
               path: ["."]
             })
    end

    test "given invalid min Date, when some Date, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~D[2000-01-01])
        |> Date.check(:min, "2000-01-01", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "min value must be a Date",
               path: ["."]
             })
    end
  end

  describe "Z.Date.check(_, :max, _, _)/4" do
    test "given min Date, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Date.check(:max, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when not a Date, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Date.check(:max, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when Date early enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~D[2000-01-01])
        |> Date.check(:max, ~D[2000-01-01], Context.new("."))

      assert result.status == :valid
    end

    test "given min Date, when Date too late, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~D[2000-01-02])
        |> Date.check(:max, ~D[2000-01-01], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "input is too late",
               path: ["."]
             })
    end

    test "given invalid min Date, when some Date, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~D[2000-01-01])
        |> Date.check(:max, "2000-01-01", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "max value must be a Date",
               path: ["."]
             })
    end
  end

  describe "Z.Date.validate/3" do
    test "given some valid string, when :parse and other rules, set parsed value" do
      {:ok, ~D[2000-01-01]} = Date.validate("2000-01-01", [:parse])

      {:ok, ~D[2000-01-01]} = Date.validate("2000-01-01", [:required, :parse])

      {:ok, ~D[2000-01-01]} =
        Date.validate("2000-01-01", [
          :required,
          :parse,
          min: ~D[2000-01-01],
          max: ~D[2000-01-01]
        ])
    end

    test "given some DateTime or NaiveDateTime, when :trunc, set Date value" do
      {:ok, ~D[2000-01-01]} = Date.validate(~U[2000-01-01 23:00:07Z], [:trunc])
      {:ok, ~D[2000-01-01]} = Date.validate(~N[2000-01-01 23:00:07], [:trunc])
    end
  end
end
