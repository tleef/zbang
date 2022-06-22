defmodule Bliss.String.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, String}

  describe "Bliss.String.check(_, :trim, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:trim, true, Context.new())

      assert result.status == :valid
    end

    test "given `true`, when some value, returns result with trimmed value" do
      result =
        Result.new()
        |> Result.set_value("\n  some\n  ")
        |> String.check(:trim, true, Context.new())

      assert result.value == "some"
    end

    test "given to_trim, when some value, returns result with trimmed value" do
      result =
        Result.new()
        |> Result.set_value("a  some  a")
        |> String.check(:trim, "a", Context.new())

      assert result.value == "  some  "
    end
  end

  describe "Bliss.String.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> String.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when non-binary value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> String.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: []
             })
    end

    test "given empty options, when empty string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("")
        |> String.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "input is not allowed to be empty",
               path: []
             })
    end

    test "given :allow_empty, when empty string value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("")
        |> String.check(:type, [:allow_empty], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when invalid string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(<<0xFFFF::16>>)
        |> String.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "input is not a valid string",
               path: []
             })
    end
  end

  describe "Bliss.String.check(_, :length, _, _)/4" do
    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("short")
        |> String.check(:length, 6, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "input does not have correct length",
               path: []
             })
    end

    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("too long")
        |> String.check(:length, 6, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "input does not have correct length",
               path: []
             })
    end

    test "given length, when correct length, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("correct")
        |> String.check(:length, 7, Context.new())

      assert result.status == :valid
    end
  end
end
