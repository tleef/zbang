defmodule Bliss.Date.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, Date}

  describe "Bliss.Date.check(_, :parse, _, _)/4" do
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

      assert Enum.member?(result.errors, %Error{
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

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a Date",
               path: ["."]
             })
    end
  end

  describe "Bliss.Date.check(_, :trunc, _, _)/4" do
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
end
