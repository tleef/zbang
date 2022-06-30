defmodule Bliss.Struct.Test do
  use ExUnit.Case, async: true

  defmodule MyStruct do
    use Bliss.Struct, rules: [:cast, unknown_keys: :ignore]

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
    end
  end

  describe "MyStruct.__bliss__/1" do
    test "given MyStruct, when __bliss__(:type), returns MyStruct" do
      assert MyStruct.__bliss__(:type) == MyStruct
    end

    test "given MyStruct, when __bliss__(:options), returns Bliss.Struct options" do
      assert MyStruct.__bliss__(:options) == Bliss.Struct.__bliss__(:options)
    end

    test "given MyStruct, when __bliss__(:rules), returns given rules" do
      assert MyStruct.__bliss__(:rules) == [:cast, {:unknown_keys, :ignore}]
    end

    test "given MyStruct, when __bliss__(:fields), returns defined fields" do
      assert MyStruct.__bliss__(:fields) == [
               {:hello, Bliss.String,
                [
                  :required,
                  :trim,
                  default: "hello",
                  length: {5, message: ":hello must be length 5"}
                ]},
               {:world, Bliss.Any,
                [
                  :required,
                  default: "world",
                  equals: "world"
                ]}
             ]
    end
  end
end
