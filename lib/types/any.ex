defmodule Bliss.Any do
  alias Bliss.{Result, Error, Context}

  use Bliss.Type

  def validate(input, options \\ [], context \\ Context.new()) do
    Result.new() |> Result.set_value(input) |> check(options, context)
  end

  def check(result, options, context) do
    result
    |> maybe_check(:default, options, context)
    |> maybe_check(:required, options, context)
    |> maybe_check(:equals, options, context)
  end

  def check(%Result{value: nil} = result, :default, value, _) do
    result |> Result.set_value(value)
  end

  def check(result, :required, false, _) do
    result
  end

  def check(result, :required, nil, context) do
    check(result, :required, [], context)
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

  def check(result, :equals, {value, options}, context) do
    message = Keyword.get(options, :message, "input does not equal literal")

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

  def check(result, _, _, _) do
    result
  end
end
