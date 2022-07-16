# Z!

Z! is a schema description and data validation library.
Inspired by libraries like [Joi](https://joi.dev/), [Yup](https://github.com/jquense/yup), and [Zod](https://zod.dev/) from the JavaScript community, 
Z! helps you describe schemas for your structs and validate their data at runtime.

## Installation

This package can be installed by adding `zbang` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zbang, "~> 1.0.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/zbang](https://hexdocs.pm/zbang)

## Types

Many types can be validated with Z!. Below is a list of built-in primitive types,
but you can also define custom types of your own.

### Any
_Module_: `Z.Any`
_Shorthand:_ `:any`

**Rules**
- `:default` - If the input is `nil`, sets input to given value
- `:required` - Asserts that input is not `nil`
- `:equals` - Asserts that input is equal to given value
- `:enum` - Asserts that input is in list of given values

> Note: The rules for `Z.Any` may be used for all other types as well since every type is implicitly a `Z.Any`

### Atom
_Module_: `Z.Atom`
_Shorthand:_ `:atom`

**Rules**
- `:parse` - If input is a string, try to parse it to an atom

### Boolean
_Module_: `Z.Boolean`
_Shorthand:_ `:boolean`

**Rules**
- `:parse` - if input is a string, try to parse it to a boolean

### Date
_Module_: `Z.Date`
_Shorthand:_ `:date`

**Rules**
- `:parse` - If input is a string, try to parse it to a Date
- `:trunc` - If input is a DateTime or NaiveDateTime, convert it to a Date
- `:min` - Asserts that the input is at least the given Date or after
- `:max` - Asserts that the input is at most the given Date or before

### DateTime
_Module_: `Z.DateTime`
_Shorthand:_ `:date_time`

**Rules**
- `:parse` - If input is a string, try to parse it to a DateTime
- `:allow_int` - If input is an integer, try to convert it to a DateTime
- `:shift` - Shift the input to the same point in time at the given timezone
- `:trunc` - Truncates the microsecond field of the input to the given precision
- `:min` - Asserts that the input is at least the given DateTime or after
- `:max` - Asserts that the input is at most the given DateTime or before

### Float
_Module_: `Z.Float`
_Shorthand:_ `:float`

**Rules**
- `:parse` - If input is a string, try to parse it to a float
- `:allow_int` - If input is an integer, convert it to a float
- `:min` - Asserts that input is greater than or equal to given value
- `:max` - Asserts that input is less than or equal to given value
- `:greater_than` - Asserts that input is greater than given value
- `:less_than` - Asserts that input is less than given value

### Integer
_Module_: `Z.Integer`
_Shorthand:_ `:integer`

**Rules**
- `:parse` - If input is a string, try to parse it to an integer
- `:trunc` - If input is a float, truncate it to an integer
- `:min` - Asserts that input is greater than or equal to given value
- `:max` - Asserts that input is less than or equal to given value
- `:greater_than` - Asserts that input is greater than given value
- `:less_than` - Asserts that input is less than given value

### List
_Module_: `Z.List`
_Shorthand:_ `:list`

**Rules**
- `:items` - Validates the items in the input list
- `:length` - Asserts that input length is equal to the given value
- `:min` - Asserts that input length is at least the given length
- `:max` - Asserts that input length is at most the given length

### Map
_Module_: `Z.Map`
_Shorthand:_ `:map`

**Rules**
- `:atomize_keys` - If key is a string, try to parse it to an atom (only existing atoms by default)
- `:size` - Asserts that the input size is equal to the given value
- `:min` - Asserts that the input size is at least the given value
- `:max` - Asserts that the input size is at most the given value

### String
_Module_: `Z.String`
_Shorthand:_ `:string`

**Rules**
- `:trim` - Trims any leading or trailing whitespace from the input
- `:length` - Asserts that input length is equal to the given value
- `:min` - Asserts that input length is at least the given length
- `:max` - Asserts that input length is at most the given length

### Struct
_Module_: `Z.Struct`

**Rules**
- `:cast` - If the input is a Map, try to cast it to the given struct

> Note: Don't use `Z.Struct` directly. Instead, define your own struct with `use Z.Struct` and a `schema` block

### Time
_Module_: `Z.Time`
_Shorthand:_ `:time`

**Rules**
- `:parse` - If input is a string, try to parse it to a Time
- `:trunc` - Truncates the microsecond field of the input to the given precision
- `:min` - Asserts that the input is at least the given Time or after
- `:max` - Asserts that the input is at most the given Time or before

## Describing Schemas

_Example_
```elixir
defmodule Money do
  use Z.Struct

  schema do
    field :amount, :float, [:required, :parse, min: 0.0]
    field :currency, :string, [:required, default: "USD", enum: ["USD", "EUR", "BTC"]]
  end
end

defmodule Book do
  use Z.Struct

  schema do
    field :title, :string, [:required]
    field :author, :string, [:required, default: "Unknown"]
    field :description, :string
    field :price, Money, [:required, :cast]
  end
end
```

In the above example, we are defining two structs by employing `use Z.Struct` with a `schema` block where `fields` are defined. When you define a struct in this way, `Z.Struct` will call `defstruct` for you and create an Elixir struct with defaults when given. In addition, it will define a `validate` function on your struct module that can be used to validate values at runtime.

The `validate` function uses the fields defined in the `schema` block to automatically assert the type of each value as well as assert that the given rules are being followed.

Each `field` takes a `name`, `type` and optional `rules`. The `name` must be an atom. The `type` must also be an atom and can either be a built-in type or a custom type e.g. the `Money` type used by the `:price` field in the example above. The `rules` vary depending on the `type` given. See [here](#types) for a list of all rules per type.

## Validation

Validating data is as simple as calling `validate` on the type that you would like to assert and passing in optional rules. The validate function will return either `{:ok, value}` or `{:error, errors}`.

_Examples_
```elixir
Z.String.validate("hello world")
{:ok, "hello world"}

Z.String.validate("oops", length: 5)
{:error,
 %Z.Error{
   issues: [
     %Z.Issue{
       code: "too_small",
       message: "input does not have correct length",
       path: ["."]
     }
   ],
   message: ""
 }}
 
Z.String.validate(nil, [:required, default: "sleepy bear"])
{:ok, "sleepy bear"}

Book.validate(%{title: "I <3 Elixir", price: %{amount: "1.00"}})
{:error,
 %Z.Error{
   issues: [
     %Z.Issue{code: "invalid_type", message: "input is not a Book", path: ["."]}
   ],
   message: ""
 }}
 
Book.validate(%{title: "I <3 Elixir", price: %{amount: "1.00"}}, [:cast])
{:ok,
 %Book{
   author: "Unknown",
   description: nil,
   price: %Money{amount: 1.0, currency: "USD"},
   title: "I <3 Elixir"
 }}
```