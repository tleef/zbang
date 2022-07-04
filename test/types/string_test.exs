defmodule Bliss.String.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, String}

  describe "Bliss.String.check(_, :trim, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
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
  end

  describe "Bliss.String.check(_, :type, _, _)/4" do
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

      assert Enum.member?(result.errors, %Error{
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

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "input is not a valid string",
               path: ["."]
             })
    end
  end

  describe "Bliss.String.check(_, :length, _, _)/4" do
    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("short")
        |> String.check(:length, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
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

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
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
  end

  describe "Bliss.String.check(_, :min, _, _)/4" do
    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("short")
        |> String.check(:min, 6, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
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

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too short",
               path: ["."]
             })
    end
  end

  describe "Bliss.String.check(_, :max, _, _)/4" do
    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("too long")
        |> String.check(:max, 7, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
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
  end

  describe "Bliss.String.validate/3" do
    test "given some padded value, when :trim value, set trimmed value" do
      {:ok, "some"} = String.validate(" some ", [:trim])
    end

    test "given long value, when check :length, check length" do
      {:error, errors} = String.validate("way too long", length: {8, message: "too long"})

      assert Enum.member?(errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "too long",
               path: ["."]
             })
    end

    test "given some padded value, when :trim and check :length, trim value and check length" do
      {:ok, "some"} = String.validate(" some ", [:trim, length: 4])
    end
  end
end
