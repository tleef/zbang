defmodule Z.Atom.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Issue, Context, Atom}

  describe "Z.Atom.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Atom.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some atom, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(:hello)
        |> Atom.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when \"oops\" and atom doesn't exist, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("oops")
        |> Atom.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as an atom",
               path: ["."]
             })
    end

    test "given `true`, when \"hello\" and atom exists, returns result with parsed atom" do
      _ = :hello

      result =
        Result.new()
        |> Result.set_value("hello")
        |> Atom.check(:parse, true, Context.new("."))

      assert result.value == :hello
    end

    test "given `:dangerously_allow_non_existing`, when \"goodbye\", returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("goodbye")
        |> Atom.check(:parse, :dangerously_allow_non_existing, Context.new("."))

      assert result.value == :goodbye
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("hello")
        |> Atom.check(:parse, false, Context.new("."))

      assert result.value == "hello"
    end
  end

  describe "Z.Atom.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Atom.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when boolean value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(:hello)
        |> Atom.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when string value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("oops")
        |> Atom.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not an atom",
               path: ["."]
             })
    end
  end

  describe "Z.Atom.validate/3" do
    test "given some boolean string value, when :parse, set parsed value" do
      {:ok, :hello} = Atom.validate(:hello, [])
      {:ok, :hello} = Atom.validate("hello", [:parse])
      {:ok, :goodbye} = Atom.validate("goodbye", parse: :dangerously_allow_non_existing)
    end
  end
end
