# Bliss

Bliss is a schema description and data validation library. 
Inspired by libraries like [Joi](https://joi.dev/), [Yup](https://github.com/jquense/yup), and [Zod](https://zod.dev/) from the JavaScript community, 
Bliss helps you describe schemas for your structs and validate their data at runtime.

## Installation

This package can be installed by adding `bliss` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bliss, "~> 1.0.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/bliss](https://hexdocs.pm/bliss)

## Types

Many types can be validated with Bliss. Below is a list of built-in primitive types, 
but you can also define custom types of your own.

### Any
_Module_: `Bliss.Any`
_Shorthand:_ `:any`

**Rules**
- `:default` - If the input is `nil`, sets input to given value
- `:required` - Asserts that input is not `nil`
- `:equals` - Asserts that input is equal to given value
- `:enum` - Asserts that input is in list of given values

> Note: The rules for `Bliss.Any` may be used for all other types as well since every type is implicitly a `Bliss.Any`

### Atom
_Module_: `Bliss.Atom`
_Shorthand:_ `:atom`

**Rules**
- `:parse` - If input is a string, try to parse it to an atom

### Boolean
_Module_: `Bliss.Boolean`
_Shorthand:_ `:boolean`

**Rules**
- `:parse` - if input is a string, try to parse it to a boolean

### Date
_Module_: `Bliss.Date`
_Shorthand:_ `:date`

**Rules**
- `:parse` - If input is a string, try to parse it to a Date
- `:trunc` - If input is a DateTime or NaiveDateTime, convert it to a Date
- `:min` - Asserts that the input is at least the given Date or after
- `:max` - Asserts that the input is at most the given Date or before

### DateTime
_Module_: `Bliss.DateTime`
_Shorthand:_ `:date_time`

**Rules**
- `:parse` - If input is a string, try to parse it to a DateTime
- `:allow_int` - If input is an integer, try to convert it to a DateTime
- `:shift` - Shift the input to the same point in time at the given timezone
- `:trunc` - Truncates the microsecond field of the input to the given precision
- `:min` - Asserts that the input is at least the given DateTime or after
- `:max` - Asserts that the input is at most the given DateTime or before

### Float
_Module_: `Bliss.Float`
_Shorthand:_ `:float`

**Rules**
- `:parse` - If input is a string, try to parse it to a float
- `:allow_int` - If input is an integer, convert it to a float
- `:min` - Asserts that input is greater than or equal to given value
- `:max` - Asserts that input is less than or equal to given value
- `:greater_than` - Asserts that input is greater than given value
- `:less_than` - Asserts that input is less than given value

### Integer
_Module_: `Bliss.Integer`
_Shorthand:_ `:integer`

**Rules**
- `:parse` - If input is a string, try to parse it to an integer
- `:trunc` - If input is a float, truncate it to an integer
- `:min` - Asserts that input is greater than or equal to given value
- `:max` - Asserts that input is less than or equal to given value
- `:greater_than` - Asserts that input is greater than given value
- `:less_than` - Asserts that input is less than given value

### List
_Module_: `Bliss.List`
_Shorthand:_ `:list`

**Rules**
- `:items` - Validates the items in the input list
- `:length` - Asserts that input length is equal to the given value
- `:min` - Asserts that input length is at least the given length
- `:max` - Asserts that input length is at most the given length

### Map
_Module_: `Bliss.Map`
_Shorthand:_ `:map`

**Rules**
- `:atomize_keys` - If key is a string, try to parse it to an atom (only existing atoms by default)
- `:size` - Asserts that the input size is equal to the given value
- `:min` - Asserts that the input size is at least the given value
- `:max` - Asserts that the input size is at most the given value

### String
_Module_: `Bliss.String`
_Shorthand:_ `:string`

**Rules**
- `:trim` - Trims any leading or trailing whitespace from the input
- `:length` - Asserts that input length is equal to the given value
- `:min` - Asserts that input length is at least the given length
- `:max` - Asserts that input length is at most the given length

### Time
_Module_: `Bliss.Time`
_Shorthand:_ `:time`

**Rules**
- `:parse` - If input is a string, try to parse it to a Time
- `:trunc` - Truncates the microsecond field of the input to the given precision
- `:min` - Asserts that the input is at least the given Time or after
- `:max` - Asserts that the input is at most the given Time or before