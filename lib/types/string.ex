defmodule Bliss.String do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type, options: Bliss.Any.__bliss__(:options) ++ [:trim, :length]

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
    |> maybe_check(:trim, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
    |> maybe_check(:length, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
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

  def check(result, _rule, _options, _context) when not is_binary(result.value) do
    result
  end

  def check(result, :trim, false, _context) do
    result
  end

  def check(result, :trim, true, _context) do
    result |> Result.set_value(result.value |> String.trim())
  end

  def check(result, :trim, to_trim, context) when not is_binary(to_trim) do
    message = "unable to trim string with to_trim: #{inspect(to_trim)}, to_trim must be a string"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :trim, to_trim, _context) do
    result |> Result.set_value(result.value |> String.trim(to_trim))
  end

  def check(result, :length, {length, _options}, context) when not is_integer(length) do
    message = "unable to check length with length: #{inspect(length)}, length must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :length, {length, options}, context) do
    cond do
      String.length(result.value) < length ->
        message = Keyword.get(options, :message, "input does not have correct length")

        result
        |> Result.add_error(
          Error.new(
            Error.Codes.too_small(),
            message,
            context
          )
        )

      String.length(result.value) > length ->
        message = Keyword.get(options, :message, "input does not have correct length")

        result
        |> Result.add_error(
          Error.new(
            Error.Codes.too_big(),
            message,
            context
          )
        )

      true ->
        result
    end
  end

  def check(result, :length, length, context) do
    check(result, :length, {length, []}, context)
  end

  def check(result, :min, {length, _options}, context) when not is_integer(length) do
    message =
      "unable to check min length with length: #{inspect(length)}, length must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :min, {length, options}, context) do
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

  def check(result, :min, length, context) do
    check(result, :min, {length, []}, context)
  end

  def check(result, :max, {length, _options}, context) when not is_integer(length) do
    message =
      "unable to check max length with length: #{inspect(length)}, length must be an integer"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :max, {length, options}, context) do
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

  def check(result, :max, length, context) do
    check(result, :max, {length, []}, context)
  end
end
