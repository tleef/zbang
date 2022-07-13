defmodule Bliss.Float do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options:
      Bliss.Any.__bliss__(:options) ++ [:parse, :allow_int, :min, :max, :greater_than, :less_than]

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
    |> maybe_check(:parse, rules, context)
    |> maybe_check(:allow_int, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
    |> maybe_check(:greater_than, rules, context)
    |> maybe_check(:less_than, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :parse, _enabled, _context) when not is_binary(result.value) do
    result
  end

  def check(result, :parse, false, _context) do
    result
  end

  def check(result, :parse, true, context) do
    case Float.parse(result.value) do
      {float, _} ->
        result |> Result.set_value(float)

      :error ->
        message = "unable to parse input as a float"

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

  def check(result, :allow_int, _enabled, _context) when not is_integer(result.value) do
    result
  end

  def check(result, :allow_int, false, _context) do
    result
  end

  def check(result, :allow_int, true, _context) do
    result |> Result.set_value(result.value / 1)
  end

  def check(result, :type, options, context) when not is_float(result.value) do
    message = Keyword.get(options, :message, "input is not a float")

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

  def check(result, _rule, _options, _context) when not is_float(result.value) do
    result
  end

  def check(result, :min, {value, _options}, context) when not is_float(value) do
    message = "min value must be a float"

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

  def check(result, :max, {value, _options}, context) when not is_float(value) do
    message = "max value must be a float"

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

  def check(result, :greater_than, {value, _options}, context) when not is_float(value) do
    message = "greater_than value must be a float"

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

  def check(result, :less_than, {value, _options}, context) when not is_float(value) do
    message = "less_than value must be a float"

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
