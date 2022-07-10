defmodule Bliss.List.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Result, Error, Context, List}

  defmodule Book do
    use Bliss.Struct

    schema do
      field(:title, :string, [:required])
      field(:author, :string, [:required, default: "unknown"])
    end
  end

  describe "Bliss.List.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> List.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-list value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("Im a list")
        |> List.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a list",
               path: ["."]
             })
    end

    test "given empty options, when charlist value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value('Im a list')
        |> List.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when string list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when map list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value([%{foo: "foo"}, %{bar: "bar"}, %{baz: "baz"}])
        |> List.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when empty list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value([])
        |> List.check(:type, [], Context.new("."))

      assert result.status == :valid
    end
  end

  describe "Bliss.List.check(_, :length, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> List.check(:length, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("Im a list")
        |> List.check(:length, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:length, 4, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input does not have correct length",
               path: ["."]
             })
    end

    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:length, 2, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input does not have correct length",
               path: ["."]
             })
    end

    test "given length, when correct length, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:length, 3, Context.new("."))

      assert result.status == :valid
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:length, "3", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check length with length: \"3\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Bliss.List.check(_, :min, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> List.check(:min, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> List.check(:min, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too short, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:min, 4, Context.new("."))

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
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:min, 3, Context.new("."))

      assert result.status == :valid
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:min, "1", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message:
                 "unable to check min length with length: \"1\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Bliss.List.check(_, :max, _, _)/4" do
    test "given length, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> List.check(:max, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when not a list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> List.check(:max, 6, Context.new("."))

      assert result.status == :valid
    end

    test "given length, when too long, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:max, 2, Context.new("."))

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
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:max, 3, Context.new("."))

      assert result.status == :valid
    end

    test "given invalid length, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:max, "3", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message:
                 "unable to check max length with length: \"3\", length must be an integer",
               path: ["."]
             })
    end
  end

  describe "Bliss.List.check(_, :items, _, _)/4" do
    test "given string type, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> List.check(:items, :string, Context.new("."))

      assert result.status == :valid
    end

    test "given string type, when not a list, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> List.check(:items, :string, Context.new("."))

      assert result.status == :valid
    end

    test "given string type, when a string list, returns a valid result" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "baz"])
        |> List.check(:items, :string, Context.new("."))

      assert result.status == :valid
    end

    test "given string type with :required, when string list with nil, returns an invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(["foo", nil, "buzz"])
        |> List.check(:items, {:string, [:required]}, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is required",
               path: [".", 1]
             })
    end

    test "given string type with rules, when invalid string list, returns an invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "buzz"])
        |> List.check(:items, {:string, [length: 3]}, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input does not have correct length",
               path: [".", 2]
             })
    end

    test "given Book type, when Book list, returns a valid result" do
      result =
        Result.new()
        |> Result.set_value([
          %Book{title: "foo"},
          %Book{title: "bar"},
          %Book{title: "baz"}
        ])
        |> List.check(:items, Book, Context.new("."))

      assert result.status == :valid
    end

    test "given Book type, when invalid Book list, returns an invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value([
          %Book{title: "foo"},
          %Book{},
          %{title: "baz"}
        ])
        |> List.check(:items, Book, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is required",
               path: [".", 1, :title]
             })

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Bliss.List.Test.Book",
               path: [".", 2]
             })
    end

    test "given Book type with :cast, when map list, casts maps to Books and returns a valid result" do
      result =
        Result.new()
        |> Result.set_value([
          %{title: "foo", author: "turing"},
          %{title: "bar"},
          %{title: "baz"}
        ])
        |> List.check(:items, {Book, [:cast]}, Context.new("."))

      assert result.status == :valid

      assert result.value == [
               %Book{title: "foo", author: "turing"},
               %Book{title: "bar", author: "unknown"},
               %Book{title: "baz", author: "unknown"}
             ]
    end

    test "given unknown type, when string list, returns an invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "buzz"])
        |> List.check(:items, :unknown, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check items of type: :unknown, unknown type",
               path: ["."]
             })
    end

    test "given non-atom type, when string list, returns an invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(["foo", "bar", "buzz"])
        |> List.check(:items, "string", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check items of type: \"string\", type must be an atom",
               path: ["."]
             })
    end
  end

  describe "Bliss.List.validate/3" do
    test "given a padded string list with nils, when :trim items with :default, set trimmed and defaulted list" do
      {:ok, ["foo", "bar", "baz", "buzz"]} =
        List.validate([" foo ", "bar", nil, "buzz"],
          length: 4,
          items: {:string, [:required, :trim, default: "baz", min: 3]}
        )
    end
  end
end
