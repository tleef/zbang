defmodule Bliss.String do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type, options: Bliss.Any.__options__() ++ [:trim, :length]

  def check(result, options, context) do
    result
    |> Any.check(options, context)
    |> maybe_check(:trim, options, context)
    |> check(:type, options, context)
    |> maybe_check(:length, options, context)
  end

  def check(%Result{value: nil} = result, _, _, _) do
    result
  end

  def check(result, :trim, nil, context) do
    check(result, :trim, true, context)
  end

  def check(result, :trim, true, _) do
    result |> Result.set_value(result.value |> String.trim())
  end

  def check(result, :trim, to_trim, _) when is_binary(to_trim) do
    result |> Result.set_value(result.value |> String.trim(to_trim))
  end

  def check(result, :type, options, context) when not is_binary(result.value) do
    message = Keyword.get(options, :parts, "input is not a valid string")

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
      message = Keyword.get(options, :parts, "input is not a valid string")

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

  def check(result, :length, {value, options}, context) do
    message = Keyword.get(options, :message, "input does not have correct length")

    if String.length(result.value) == value do
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

  def check(result, :length, value, context) do
    check(result, :length, {value, []}, context)
  end

  def check(result, :min, {value, options}, context) do
    message = Keyword.get(options, :message, "input is too short")

    if String.length(result.value) >= value do
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

  def check(result, :min, value, context) do
    check(result, :min, {value, []}, context)
  end

  def check(result, :max, {value, options}, context) do
    message = Keyword.get(options, :message, "input is too long")

    if String.length(result.value) <= value do
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

  def check(result, :max, value, context) do
    check(result, :max, {value, []}, context)
  end

  def check(result, _, _, _) do
    result
  end
end
