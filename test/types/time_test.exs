defmodule Bliss.Time.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, Time}

  describe "Bliss.Time.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Time.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some Time, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~T[23:50:07])
        |> Time.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("23:50:07")
        |> Time.check(:parse, true, Context.new("."))

      assert result.value == ~T[23:50:07]
    end

    test "given `true`, when some ISO 8601 string with microseconds, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("23:50:07.0123456")
        |> Time.check(:parse, true, Context.new("."))

      assert result.value == ~T[23:50:07.012345]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("23:50:07")
        |> Time.check(:parse, false, Context.new("."))

      assert result.value == "23:50:07"
    end

    test "given format :iso8601, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("23:50:07")
        |> Time.check(:parse, :iso8601, Context.new("."))

      assert result.value == ~T[23:50:07]
    end

    test "given invalid format, when some ISO 8601 string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("23:50:07")
        |> Time.check(:parse, :invalid, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to parse Time with format: :invalid, format must be :iso8601",
               path: ["."]
             })
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("23:50:61")
        |> Time.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a Time",
               path: ["."]
             })
    end
  end

  describe "Bliss.Time.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Time.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when Time value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~T[23:50:07.123])
        |> Time.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-Time value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Time.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Time",
               path: ["."]
             })
    end

    test "given empty options, when NaiveDateTime value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(~N[2000-01-01 23:00:07])
        |> Time.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Time",
               path: ["."]
             })
    end
  end
end
