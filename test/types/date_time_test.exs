defmodule Bliss.DateTime.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, DateTime}

  describe "Bliss.DateTime.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2016-05-24 13:26:08Z])
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.value == ~U[2015-01-23 23:50:07Z]
    end

    test "given `true`, when some ISO 8601 string with offset, returns result with parsed UTC value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07.123+02:30")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.value == ~U[2015-01-23 21:20:07.123Z]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, false, Context.new("."))

      assert result.value == "2015-01-23T23:50:07Z"
    end

    test "given format :iso8601, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, :iso8601, Context.new("."))

      assert result.value == ~U[2015-01-23 23:50:07Z]
    end

    test "given invalid format, when some ISO 8601 string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, :invalid, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to parse DateTime with format: :invalid, format must be :iso8601",
               path: ["."]
             })
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a DateTime",
               path: ["."]
             })
    end
  end
end
