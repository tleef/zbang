defmodule Bliss.Integer do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options:
      Bliss.Any.__bliss__(:options) ++ [:parse, :trunc, :min, :max, :greater_than, :less_than]

  def check(result, rules, context) do
    result
    |> Any.check(rules, context)
    |> maybe_check(:parse, rules, context)
    |> maybe_check(:trunc, rules, context)
    |> check(:type, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
    |> maybe_check(:greater_than, rules, context)
    |> maybe_check(:less_than, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :parse, _base, _context) when not is_binary(result.value) do
    result
  end

  def check(result, :parse, false, _context) do
    result
  end

  def check(result, :parse, true, context) do
    check(result, :parse, 10, context)
  end

  def check(result, :parse, base, context) when base not in 2..36 do
    message = "unable to parse integer with base: #{inspect(base)}, base must be in 2..36"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :parse, base, context) do
    case Integer.parse(result.value, base) do
      {int, _} ->
        result |> Result.set_value(int)

      :error ->
        message = "unable to parse input as an integer"

        result
        |> Result.add_error(
          Error.new(
            Error.Codes.invalid_string(),
            message,
            context
          )
        )
    end
  end

  def check(result, :trunc, _enabled, _context) when not is_float(result.value) do
    result
  end

  def check(result, :trunc, false, _context) do
    result
  end

  def check(result, :trunc, true, _context) do
    result |> Result.set_value(trunc(result.value))
  end

  def check(result, :type, options, context) when not is_integer(result.value) do
    message = Keyword.get(options, :message, "input is not an integer")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  def check(result, :type, _options, _context) do
    result
  end

  def check(result, _rule, _options, _context) when not is_integer(result.value) do
    result
  end

  def check(result, :min, {value, _options}, context) when not is_integer(value) do
    message = "min value must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :min, {value, options}, context) when result.value < value do
    message = Keyword.get(options, :message, "input is too small")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.too_small(),
        message,
        context
      )
    )
  end

  def check(result, :min, {_value, _options}, _context) do
    result
  end

  def check(result, :min, value, context) do
    check(result, :min, {value, []}, context)
  end

  def check(result, :max, {value, _options}, context) when not is_integer(value) do
    message = "max value must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :max, {value, options}, context) when result.value > value do
    message = Keyword.get(options, :message, "input is too big")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.too_big(),
        message,
        context
      )
    )
  end

  def check(result, :max, {_value, _options}, _context) do
    result
  end

  def check(result, :max, value, context) do
    check(result, :max, {value, []}, context)
  end

  def check(result, :greater_than, {value, _options}, context) when not is_integer(value) do
    message = "greater_than value must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :greater_than, {value, options}, context) when result.value <= value do
    message = Keyword.get(options, :message, "input is too small")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.too_small(),
        message,
        context
      )
    )
  end

  def check(result, :greater_than, {_value, _options}, _context) do
    result
  end

  def check(result, :greater_than, value, context) do
    check(result, :greater_than, {value, []}, context)
  end

  def check(result, :less_than, {value, _options}, context) when not is_integer(value) do
    message = "less_than value must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :less_than, {value, options}, context) when result.value >= value do
    message = Keyword.get(options, :message, "input is too big")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.too_big(),
        message,
        context
      )
    )
  end

  def check(result, :less_than, {_value, _options}, _context) do
    result
  end

  def check(result, :less_than, value, context) do
    check(result, :less_than, {value, []}, context)
  end
end
