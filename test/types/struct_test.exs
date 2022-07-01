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
      field(:hello, :string, [
        :required,
        :trim,
        default: "hello",
        length: {5, message: ":hello must be length 5"}
      ])

      field(:world, :any, [
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
               hello:
                 {Bliss.String,
                  [
                    :required,
                    :trim,
                    default: "hello",
                    length: {5, message: ":hello must be length 5"}
                  ]},
               world:
                 {Bliss.Any,
                  [
                    :required,
                    default: "world",
                    equals: "world"
                  ]},
               price: {Bliss.Struct.Test.MySubStruct, [:required, :cast]}
             ]
    end
  end

  describe "MyStruct.validate/3" do
    test "given a valid map, when validating with :cast, returns a valid result" do
      result =
        MyStruct.validate(%{hello: "hello", world: "world", price: %{amount: "1.00"}}, [:cast])

      assert result.status == :valid

      assert result.value == %MyStruct{
               hello: "hello",
               world: "world",
               price: %MySubStruct{amount: "1.00", currency: "USD"}
             }
    end

    test "given a valid map, when validating without :cast, returns an invalid result with an error" do
      result = MyStruct.validate(%{hello: "hello", world: "world"}, [])

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a Bliss.Struct.Test.MyStruct",
               path: []
             })
    end
  end
end
