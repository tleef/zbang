defmodule Bliss.Struct.Test do
  use ExUnit.Case, async: true

  alias Bliss.{Error}

  defmodule MySubStruct do
    use Bliss.Struct

    schema do
      field(:amount, :string, [:required])
      field(:currency, :string, [:required, default: "USD", enum: ["USD", "EUR", "BTC"]])
    end
  end

  defmodule MyStruct do
    use Bliss.Struct

    schema do
      field(:foo, :string)

      field(:bar, :string, [
        :required,
        :trim,
        length: {5, message: ":one must be length 5"}
      ])

      field(:baz, :any, [
        :required,
        default: "world",
        equals: "world"
      ])

      field(:price, MySubStruct, [:required, :cast])
    end
  end

  describe "MyStruct.__bliss__/1" do
    test "given MyStruct, when __bliss__(:type), returns MyStruct" do
      assert MyStruct.__bliss__(:type) == MyStruct
    end

    test "given MyStruct, when __bliss__(:options), returns Bliss.Struct options" do
      assert MyStruct.__bliss__(:options) == [:default, :required, :equals, :enum, :cast]
    end

    test "given MyStruct, when __bliss__(:fields), returns defined fields" do
      assert MyStruct.__bliss__(:fields) == [
               foo: {Bliss.String, []},
               bar:
                 {Bliss.String,
                  [
                    required: true,
                    trim: true,
                    length: {5, message: ":one must be length 5"}
                  ]},
               baz:
                 {Bliss.Any,
                  [
                    required: true,
                    default: "world",
                    equals: "world"
                  ]},
               price: {Bliss.Struct.Test.MySubStruct, [required: true, cast: true]}
             ]
    end
  end

  describe "MyStruct.validate/3" do
    test "given a valid map, when validating with :cast, returns a valid result" do
      {:ok, value} =
        MyStruct.validate(
          %{foo: "hey!", bar: "hello", baz: "world", price: %{amount: "1.00", currency: "USD"}},
          [:cast]
        )

      assert value == %MyStruct{
               foo: "hey!",
               bar: "hello",
               baz: "world",
               price: %MySubStruct{amount: "1.00", currency: "USD"}
             }
    end

    test "given a valid map, when validating without :cast, returns an invalid result with an error" do
      {:error, errors} =
        MyStruct.validate(
          %{foo: "hey!", bar: "hello", baz: "world", price: %{amount: "1.00", currency: "USD"}},
          []
        )

      assert Enum.member?(errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Bliss.Struct.Test.MyStruct",
               path: ["."]
             })
    end

    test "given a map with extra keys, when validating with :cast, ignores keys and returns valid result" do
      {:ok, value} =
        MyStruct.validate(
          %{
            foo: "hey!",
            bar: "hello",
            baz: "world",
            price: %{amount: "1.00", currency: "USD"},
            extra: "oops"
          },
          [:cast]
        )

      assert value == %MyStruct{
               foo: "hey!",
               bar: "hello",
               baz: "world",
               price: %MySubStruct{amount: "1.00", currency: "USD"}
             }
    end

    test "given a map missing keys with defaults, when validating with :cast, defaults the keys and returns valid result" do
      {:ok, value} =
        MyStruct.validate(%{foo: "hey!", bar: "hello", price: %{amount: "1.00"}}, [:cast])

      assert value == %MyStruct{
               foo: "hey!",
               bar: "hello",
               baz: "world",
               price: %MySubStruct{amount: "1.00", currency: "USD"}
             }
    end

    test "given a map missing non-required keys without defaults, when validating with :cast, ignores the missing keys and returns valid result" do
      {:ok, value} =
        MyStruct.validate(
          %{bar: "hello", baz: "world", price: %{amount: "1.00", currency: "USD"}},
          [:cast]
        )

      assert value == %MyStruct{
               bar: "hello",
               baz: "world",
               price: %MySubStruct{amount: "1.00", currency: "USD"}
             }
    end

    test "given a map with an invalid key, when validating with :cast, returns an invalid result with an error" do
      {:error, errors} =
        MyStruct.validate(
          %{foo: 123, bar: "hello", baz: "world", price: %{amount: "1.00", currency: "USD"}},
          [:cast]
        )

      assert Enum.member?(errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: [".", :foo]
             })
    end

    test "given a map with an invalid keys, when validating with :cast, returns an invalid result with errors" do
      {:error, errors} =
        MyStruct.validate(
          %{foo: 123, bar: "hello", baz: "world", price: %{amount: "1.00", currency: "$"}},
          [:cast]
        )

      assert Enum.member?(errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: [".", :foo]
             })

      assert Enum.member?(errors, %Error{
               code: Error.Codes.invalid_enum_value(),
               message: "input is not an allowed value",
               path: [".", :price, :currency]
             })
    end
  end
end
