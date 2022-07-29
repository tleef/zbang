defmodule Z.Boolean.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Issue, Context, Boolean}

  describe "Z.Boolean.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Boolean.check(:parse, true, Context.new())

      assert result.status == :valid
    end

    test "given `true`, when some boolean, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(true)
        |> Boolean.check(:parse, true, Context.new())

      assert result.status == :valid
    end

    test "given `true`, when \"true\", returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("true")
        |> Boolean.check(:parse, true, Context.new())

      assert result.value == true
    end

    test "given `true`, when \"FALSE\", returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("FALSE")
        |> Boolean.check(:parse, true, Context.new())

      assert result.value == false
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("TRUE")
        |> Boolean.check(:parse, false, Context.new())

      assert result.value == "TRUE"
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("oops")
        |> Boolean.check(:parse, true, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a boolean",
               path: ["."]
             })
    end
  end

  describe "Z.Boolean.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Boolean.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when boolean value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(true)
        |> Boolean.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("true")
        |> Boolean.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a boolean",
               path: ["."]
             })
    end

    test "given empty options, when int value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(1)
        |> Boolean.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a boolean",
               path: ["."]
             })
    end
  end

  describe "Z.Boolean.validate/3" do
    test "given some boolean string value, when :parse, set parsed value" do
      {:ok, true} = Boolean.validate("true", [:parse])
      {:ok, true} = Boolean.validate("True", [:parse])
      {:ok, true} = Boolean.validate("TRUE", [:parse])
      {:ok, false} = Boolean.validate("false", [:parse])
      {:ok, false} = Boolean.validate("False", [:parse])
      {:ok, false} = Boolean.validate("FALSE", [:parse])
    end
  end
end
