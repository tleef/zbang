defmodule Z.Struct.Test do
  use ExUnit.Case, async: true

  alias Z.{Error, Issue}

  def utc_now do
    ~U[2016-05-24 13:26:08Z]
  end

  defmodule Money do
    use Z.Struct

    schema do
      field(:amount, :string, [:required])
      field(:currency, :string, [:required, default: "USD", enum: ["USD", "EUR", "BTC"]])
    end
  end

  defmodule Book do
    use Z.Struct

    schema do
      field(:title, :string, [
        :required,
        :trim,
        length: {5, message: ":title must be length 5"}
      ])

      field(:author, :any, [
        :required,
        default: "unknown",
        equals: "unknown"
      ])

      field(:description, :string)

      field(:price, Money, [:required, :cast])

      field(:read_at, :datetime, default: &Z.Struct.Test.utc_now/0)
    end
  end

  defmodule AllTypes do
    use Z.Struct

    schema do
      field(:my_any, :any, [:required, default: "foo", equals: "foo", enum: ["foo", "bar", "baz"]])

      field(:my_atom, :atom, [
        :required,
        :parse,
        default: :foo,
        equals: :foo,
        enum: [:foo, :bar, :baz]
      ])

      field(:my_boolean, :boolean, [
        :required,
        :parse,
        default: true,
        equals: true,
        enum: [true, false]
      ])

      field(:my_integer, :integer, [
        :required,
        :parse,
        :trunc,
        default: 1,
        equals: 1,
        enum: [1, 2, 3],
        min: 1,
        max: 3,
        greater_than: 0,
        less_than: 4
      ])

      field(:my_float, :float, [
        :required,
        :parse,
        :allow_int,
        default: 1.0,
        equals: 1.0,
        enum: [1.0, 2.0, 3.0],
        min: 1.0,
        max: 3.0,
        greater_than: 0.0,
        less_than: 4.0
      ])

      field(:my_string, :string, [
        :required,
        :trim,
        default: "foo",
        equals: "foo",
        enum: ["foo", "bar", "baz"],
        length: 3
      ])

      field(:my_map, :map, [
        :required,
        :atomize_keys,
        default: %{foo: "foo"},
        equals: %{foo: "foo"},
        enum: [%{foo: "foo"}, %{bar: "bar"}, %{baz: "baz"}],
        size: 1,
        min: 1,
        max: 1
      ])

      field(:my_list, :list, [
        :required,
        default: ["foo"],
        equals: ["foo"],
        enum: [["foo"], ["bar"], ["baz"]],
        length: 1,
        min: 1,
        max: 1,
        items: :string
      ])

      field(:my_datetime, :datetime, [
        :required,
        :parse,
        :allow_int,
        :trunc,
        default: ~U[2000-01-01 00:00:00Z],
        equals: ~U[2000-01-01 00:00:00Z],
        enum: [~U[2000-01-01 00:00:00Z], ~U[2001-01-01 00:00:00Z], ~U[2002-01-01 00:00:00Z]],
        shift: "Etc/UTC",
        min: ~U[2000-01-01 00:00:00Z],
        max: ~U[2002-01-01 00:00:00Z]
      ])

      field(:my_date, :date, [
        :required,
        :parse,
        :trunc,
        default: ~D[2000-01-01],
        equals: ~D[2000-01-01],
        enum: [~D[2000-01-01], ~D[2001-01-01], ~D[2002-01-01]],
        min: ~D[2000-01-01],
        max: ~D[2002-01-01]
      ])

      field(:my_time, :time, [
        :required,
        :parse,
        :trunc,
        default: ~T[00:00:00],
        equals: ~T[00:00:00],
        enum: [~T[00:00:00], ~T[01:00:00], ~T[02:00:00]],
        min: ~T[00:00:00],
        max: ~T[02:00:00]
      ])
    end
  end

  describe "Book.__z__/1" do
    test "given Book, when __z__(:type), returns Book" do
      assert Book.__z__(:type) == Book
    end

    test "given Book, when __z__(:options), returns Z.Struct options" do
      assert Book.__z__(:options) == [:default, :required, :equals, :enum, :cast]
    end

    test "given Book, when __z__(:fields), returns defined fields" do
      assert Book.__z__(:fields) == [
               title:
                 {Z.String,
                  [
                    required: true,
                    trim: true,
                    length: {5, message: ":title must be length 5"}
                  ]},
               author:
                 {Z.Any,
                  [
                    required: true,
                    default: "unknown",
                    equals: "unknown"
                  ]},
               description: {Z.String, []},
               price: {Z.Struct.Test.Money, [required: true, cast: true]},
               read_at: {Z.DateTime, [default: &Z.Struct.Test.utc_now/0]}
             ]
    end
  end

  describe "Book.validate/3" do
    test "given a valid map, when validating with :cast, returns a valid result" do
      {:ok, value} =
        Book.validate(
          %{
            title: "hello",
            author: "unknown",
            description: "world",
            price: %{amount: "1.00", currency: "USD"}
          },
          [:cast]
        )

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a valid map, when validating without :cast, returns an invalid result with an error" do
      {:error, error} =
        Book.validate(
          %{
            title: "hello",
            author: "unknown",
            description: "world",
            price: %{amount: "1.00", currency: "USD"}
          },
          []
        )

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a Z.Struct.Test.Book",
               path: ["."]
             })
    end

    test "given a map with extra keys, when validating with :cast, ignores keys and returns valid result" do
      {:ok, value} =
        Book.validate(
          %{
            title: "hello",
            author: "unknown",
            description: "world",
            price: %{amount: "1.00", currency: "USD"},
            extra: "oops"
          },
          [:cast]
        )

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a map missing keys with defaults, when validating with :cast, defaults the keys and returns valid result" do
      {:ok, value} =
        Book.validate(%{title: "hello", description: "world", price: %{amount: "1.00"}}, [:cast])

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a map missing non-required keys without defaults, when validating with :cast, ignores the missing keys and returns valid result" do
      {:ok, value} =
        Book.validate(
          %{title: "hello", author: "unknown", price: %{amount: "1.00", currency: "USD"}},
          [:cast]
        )

      assert value == %Book{
               title: "hello",
               author: "unknown",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a map with an invalid key, when validating with :cast, returns an invalid result with an error" do
      {:error, error} =
        Book.validate(
          %{
            title: 123,
            author: "unknown",
            description: "world",
            price: %{amount: "1.00", currency: "USD"}
          },
          [:cast]
        )

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: [".", :title]
             })
    end

    test "given a map with invalid keys, when validating with :cast, returns an invalid result with errors" do
      {:error, error} =
        Book.validate(
          %{
            title: 123,
            author: "unknown",
            description: "world",
            price: %{amount: "1.00", currency: "$"}
          },
          [:cast]
        )

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: [".", :title]
             })

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_enum_value(),
               message: "input is not an allowed value",
               path: [".", :price, :currency]
             })
    end
  end

  describe "Book.new/1" do
    test "given a valid keyword list, when new, returns a valid result" do
      {:ok, value} =
        Book.new(
          title: "hello",
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "USD"}
        )

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a valid map, when new, returns a valid result" do
      {:ok, value} =
        Book.new(%{
          title: "hello",
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "USD"}
        })

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a keyword list with invalid keys, when new, returns an invalid result with errors" do
      {:error, error} =
        Book.new(
          title: 123,
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "$"}
        )

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_type(),
               message: "input is not a valid string",
               path: [".", :title]
             })

      assert Enum.member?(error.issues, %Issue{
               code: Error.Codes.invalid_enum_value(),
               message: "input is not an allowed value",
               path: [".", :price, :currency]
             })
    end
  end

  describe "Book.new!/1" do
    test "given a valid keyword list, when new!, returns a valid result" do
      value =
        Book.new!(
          title: "hello",
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "USD"}
        )

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a valid map, when new!, returns a valid result" do
      value =
        Book.new!(%{
          title: "hello",
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "USD"}
        })

      assert value == %Book{
               title: "hello",
               author: "unknown",
               description: "world",
               price: %Money{amount: "1.00", currency: "USD"},
               read_at: ~U[2016-05-24 13:26:08Z]
             }
    end

    test "given a keyword list with invalid keys, when new!, returns an invalid result with errors" do
      assert_raise Z.Error, fn ->
        Book.new!(
          title: 123,
          author: "unknown",
          description: "world",
          price: %{amount: "1.00", currency: "$"}
        )
      end
    end
  end
end
