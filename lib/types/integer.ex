defmodule Bliss.Integer do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options: Bliss.Any.__bliss__(:options) ++ [:parse, :min, :max, :greater_than, :less_than]

  def check(result, rules, context) do
    result
    |> Any.check(rules, context)
    |> maybe_check(:parse, rules, context)
    |> check(:type, rules, context)

    #    |> maybe_check(:min, rules, context)
    #    |> maybe_check(:max, rules, context)
    #    |> maybe_check(:greater_than, rules, context)
    #    |> maybe_check(:less_than, rules, context)
  end

  def check(%Result{value: nil} = result, _rule, _options, _context) do
    result
  end

  def check(result, :parse, false, _context) do
    result
  end

  def check(result, :parse, true, context) do
    check(result, :parse, 10, context)
  end

  def check(result, :parse, base, _context) when is_binary(result.value) and base in 2..36 do
    {int, _} = result.value |> Integer.parse(base)
    result |> Result.set_value(int)
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

  def check(result, :min, {value, options}, context)
      when is_integer(value) and result.value < value do
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

  def check(result, :min, {value, _options}, _context) when is_integer(value) do
    result
  end

  def check(result, :min, value, context) when is_integer(value) do
    check(result, :min, {value, []}, context)
  end

  def check(result, :max, {value, options}, context)
      when is_integer(value) and result.value > value do
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

  def check(result, :max, {value, _options}, _context) when is_integer(value) do
    result
  end

  def check(result, :max, value, context) when is_integer(value) do
    check(result, :max, {value, []}, context)
  end
end
