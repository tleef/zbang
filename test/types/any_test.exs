defmodule Bliss.Any.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, Any}

  describe "Bliss.Any.check(_, :default, _, _)/4" do
    test "given default, when nil value, returns result with default value" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Any.check(:default, "some", Context.new())

      assert result.value == "some"
    end

    test "given default, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("some")
        |> Any.check(:default, "other", Context.new())

      assert result.value == "some"
    end
  end

  describe "Bliss.Any.check(_, :required, _, _)/4" do
    test "given empty options, when nil value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Any.check(:required, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is required",
               path: []
             })
    end

    test "given `true` options, when nil value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Any.check(:required, true, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is required",
               path: []
             })
    end

    test "given `false` options, when nil value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Any.check(:required, false, Context.new())

      assert result.status == :valid
    end

    test "given empty options, when some value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("some")
        |> Any.check(:required, [], Context.new())

      assert result.status == :valid
    end
  end

  describe "Bliss.Any.validate/3" do
    test "given nil, when :default value, set default" do
      result = Any.validate(nil, default: "some")

      assert result.value == "some"
    end

    test "given nil, when :required, check required" do
      result = Any.validate(nil, [:required])

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is required",
               path: []
             })
    end

    test "given nil, when :required with :default value, set default value and check required" do
      result = Any.validate(nil, [:required, default: "some"])

      assert result.status == :valid
      assert result.value == "some"
    end
  end
end
