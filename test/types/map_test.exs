defmodule Z.Map.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Issue, Context, Map}

  defmodule Book do
    use Z.Struct

    schema do
      field(:title, :string)
      field(:author, :string)
    end
  end

  describe "Z.Map.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when non-map value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("Im a map")
        |> Map.check(:type, [], Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a Map",
               path: ["."]
             })
    end

    test "given empty options, when struct value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%Book{})
        |> Map.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when some map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:type, [], Context.new())

      assert result.status == :valid
    end

    test "given empty options, when empty map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{})
        |> Map.check(:type, [], Context.new())

      assert result.status == :valid
    end
  end

  describe "Z.Map.check(_, :atomize_keys, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:atomize_keys, true, Context.new())

      assert result.status == :valid
    end

    test "given `true`, when some non-map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Map.check(:atomize_keys, true, Context.new())

      assert result.status == :valid
    end

    test "given `true`, when map with string key and atom doesn't exist, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{"oops" => "doesn't exist"})
        |> Map.check(:atomize_keys, true, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_string(),
               message: "unable to atomize key",
               path: [".", "oops"]
             })
    end

    test "given `true`, when map with string keys and atoms exist, returns valid result with atomized map" do
      _ = :foo
      _ = :bar

      result =
        Result.new()
        |> Result.set_value(%{"foo" => "hello", "bar" => "world"})
        |> Map.check(:atomize_keys, true, Context.new())

      assert result.status == :valid

      assert result.value == %{foo: "hello", bar: "world"}
    end

    test "given `true`, when map with mixed keys, returns valid result with atomized map" do
      _ = :foo

      result =
        Result.new()
        |> Result.set_value(%{"foo" => "foo", 2 => "two", bar: "bar"})
        |> Map.check(:atomize_keys, true, Context.new())

      assert result.status == :valid

      assert result.value == %{2 => "two", foo: "foo", bar: "bar"}
    end
  end

  describe "Z.Map.check(_, :size, _, _)/4" do
    test "given size, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:size, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when not a map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value("Im a map")
        |> Map.check(:size, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:size, 4, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input does not have correct size",
               path: ["."]
             })
    end

    test "given size, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:size, 2, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "input does not have correct size",
               path: ["."]
             })
    end

    test "given size, when correct size, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:size, 3, Context.new())

      assert result.status == :valid
    end

    test "given invalid size, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:size, "3", Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check size with size: \"3\", size must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.Map.check(_, :min, _, _)/4" do
    test "given size, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:min, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when not a map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Map.check(:min, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when too small, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:min, 4, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_small(),
               message: "input is too small",
               path: ["."]
             })
    end

    test "given size, when big enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:min, 3, Context.new())

      assert result.status == :valid
    end

    test "given invalid size, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:min, "1", Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check min size with size: \"1\", size must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.Map.check(_, :max, _, _)/4" do
    test "given size, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> Map.check(:max, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when not a map, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> Map.check(:max, 6, Context.new())

      assert result.status == :valid
    end

    test "given size, when too big, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:max, 2, Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.too_big(),
               message: "input is too big",
               path: ["."]
             })
    end

    test "given size, when small enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:max, 3, Context.new())

      assert result.status == :valid
    end

    test "given invalid size, when some value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(%{foo: "one", bar: "two", baz: "three"})
        |> Map.check(:max, "3", Context.new())

      assert result.status == :invalid

      assert Enum.member?(result.issues, %Issue{
               code: Error.Codes.invalid_arguments(),
               message: "unable to check max size with size: \"3\", size must be an integer",
               path: ["."]
             })
    end
  end

  describe "Z.Map.validate/3" do
    test "given a map with mixed keys, when :atomize_keys with :size, set atomized keys and assert size" do
      {:ok, %{2 => "two", foo: "one", baz: "three"}} =
        Map.validate(
          %{"foo" => "one", 2 => "two", baz: "three"},
          [:atomize_keys, size: 3]
        )
    end
  end
end
