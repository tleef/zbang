defmodule Bliss.Map.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, Map}

  defmodule Book do
    use Bliss.Struct

    schema do
      field(:title, :string)
      field(:author, :string)
    end
  end

  describe "Bliss.Map.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-map value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("Im a map")
        |> Map.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Map",
               path: ["."]
             })
    end

    test "given empty options, when struct value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%Book{})
        |> Map.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when some map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when empty map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{})
        |> Map.check(:type, [], Context.new("."))

      assert result.status == :valid
    end
  end
end
