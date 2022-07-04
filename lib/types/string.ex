defmodule Bliss.String do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type, options: Bliss.Any.__bliss__(:options) ++ [:trim, :length]

  def check(result, rules, context) do
    result
    |> Any.check(rules, context)
    |> maybe_check(:trim, rules, context)
    |> check(:type, rules, context)
    |> maybe_check(:length, rules, context)
  end

  def check(%Result{value: nil} = result, _rule, _options, _context) do
    result
  end

  def check(result, :trim, false, _context) do
    result
  end

  def check(result, :trim, true, _context) do
    result |> Result.set_value(result.value |> String.trim())
  end

  def check(result, :trim, to_trim, _context) when is_binary(to_trim) do
    result |> Result.set_value(result.value |> String.trim(to_trim))
  end

  def check(result, :type, options, context) when not is_binary(result.value) do
    message = Keyword.get(options, :message, "input is not a valid string")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  def check(result, :type, options, context) do
    if String.valid?(result.value) do
      result
    else
      message = Keyword.get(options, :message, "input is not a valid string")

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

  def check(result, :length, {length, options}, context) when is_integer(length) do
    message = Keyword.get(options, :message, "input does not have correct length")

    if String.length(result.value) == length do
      result
    else
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

  def check(result, :length, length, context) when is_integer(length) do
    check(result, :length, {length, []}, context)
  end

  def check(result, :min, {length, options}, context) when is_integer(length) do
    message = Keyword.get(options, :message, "input is too short")

    if String.length(result.value) >= length do
      result
    else
      result
      |> Result.add_error(
        Error.new(
          Error.Codes.too_small(),
          message,
          context
        )
      )
    end
  end

  def check(result, :min, length, context) when is_integer(length) do
    check(result, :min, {length, []}, context)
  end

  def check(result, :max, {length, options}, context) when is_integer(length) do
    message = Keyword.get(options, :message, "input is too long")

    if String.length(result.value) <= length do
      result
    else
      result
      |> Result.add_error(
        Error.new(
          Error.Codes.too_big(),
          message,
          context
        )
      )
    end
  end

  def check(result, :max, length, context) when is_integer(length) do
    check(result, :max, {length, []}, context)
  end
end
