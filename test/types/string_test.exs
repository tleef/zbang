defmodule Z.String.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Issue, Context, String}

  describe "Z.String.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-binary value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: ["."]
             })
    end

    test "given empty options, when empty string value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("")
        |> String.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when invalid string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(<<0xFFFF::16>>)
        |> String.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_string(),
               message: "input is not a valid string",
               path: ["."]
             })
    end
  end

  describe "Z.String.check(_, :trim, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:trim, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when not a string, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:trim, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some value, returns result with trimmed value" do
      result =
        Result.new()
        |> Result.set_value("\n  some\n  ")
        |> String.check(:trim, true, Context.new("."))

      assert result.value == "some"
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("\n  some\n  ")
        |> String.check(:trim, false, Context.new("."))

      assert result.value == "\n  some\n  "
    end

    test "given to_trim, when some value, returns result with trimmed value" do
      result =
        Result.new()
        |> Result.set_value("a  some  a")
        |> String.check(:trim, "a", Context.new("."))

      assert result.value == "  some  "
    end

    test "given invalid to_trim, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("a  some  a")
        |> String.check(:trim, 12, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to trim string with to_trim: 12, to_trim must be a string",
               path: ["."]
             })
    end
  end

  describe "Z.String.check(_, :length, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:length, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a string, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:length, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("short")
        |> String.check(:length, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input does not have correct length",
               path: ["."]
             })
    end

    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("too long")
        |> String.check(:length, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "input does not have correct length",
               path: ["."]
             })
    end

    test "given length, when correct length, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("correct")
        |> String.check(:length, 7, Context.new("."))

      assert result.status == :valid
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("some")
        |> String.check(:length, "4", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check length with length: \"4\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.String.check(_, :min, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:min, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a string, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:min, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("short")
        |> String.check(:min, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input is too short",
               path: ["."]
             })
    end

    test "given length, when long enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("long enough")
        |> String.check(:min, 11, Context.new("."))

      assert result.status == :valid
    end

    test "given length 1, when empty string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("")
        |> String.check(:min, 1, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input is too short",
               path: ["."]
             })
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("some")
        |> String.check(:min, "4", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message:
                 "unable to check min length with length: \"4\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.String.check(_, :max, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:max, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a string, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:max, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("too long")
        |> String.check(:max, 7, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "input is too long",
               path: ["."]
             })
    end

    test "given length, when short enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("short enough")
        |> String.check(:max, 12, Context.new("."))

      assert result.status == :valid
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("some")
        |> String.check(:max, "4", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message:
                 "unable to check max length with length: \"4\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.String.validate/3" do
    test "given some padded value, when :trim value, set trimmed value" do
      {:ok, "some"} = String.validate(" some ", [:trim])
    end

    test "given long value, when check :length, check length" do
      {:error, error} = String.validate("way too long", length: {8, message: "too long"})

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "too long",
               path: ["."]
             })
    end

    test "given some padded value, when :trim and check :length, trim value and check length" do
      {:ok, "some"} = String.validate(" some ", [:trim, length: 4])
    end
  end
end
