defmodule Bliss.Any do
  alias Bliss.{Result, Error}

  use Bliss.Type, options: [:default, :required, :equals, :enum]

  def check(result, rules, context) do
    result
    |> maybe_check(:default, rules, context)
    |> maybe_check(:required, rules, context)
    |> maybe_check(:equals, rules, context)
    |> maybe_check(:enum, rules, context)
  end

  def check(%Result{value: nil} = result, :default, value, _) do
    result |> Result.set_value(value)
  end

  def check(result, :default, _value, _context) do
    result
  end

  def check(result, :required, false, _context) do
    result
  end

  def check(result, :required, true, context) do
    check(result, :required, [], context)
  end

  def check(%Result{value: nil} = result, :required, options, context) do
    message = Keyword.get(options, :message, "input is required")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  def check(result, :required, _options, _context) do
    result
  end

  def check(result, :equals, {value, options}, context) do
    message = Keyword.get(options, :message, "input does not equal #{inspect(value)}")

    if result.value == value do
      result
    else
      result
      |> Result.add_error(
        Error.new(
          Error.Codes.invalid_literal(),
          message,
          context
        )
      )
    end
  end

  def check(result, :equals, value, context) do
    check(result, :equals, {value, []}, context)
  end

  def check(result, :enum, {value, options}, context) do
    message = Keyword.get(options, :message, "input is not an allowed value")

    if Enum.member?(value, result.value) do
      result
    else
      result
      |> Result.add_error(
        Error.new(
          Error.Codes.invalid_enum_value(),
          message,
          context
        )
      )
    end
  end

  def check(result, :enum, value, context) do
    check(result, :enum, {value, []}, context)
  end
end
