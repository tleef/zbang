defmodule Bliss.String do
  alias Bliss.{Result, Context, Error, Any}

  use Bliss.Type

  def validate(input, options \\ [], context \\ Context.new()) do
    Result.new() |> Result.set_value(input) |> check(options, context)
  end

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

  def check(result, :type, options, context) when result.value == "" do
    allow_empty = get_flag_options(options, :allow_empty)

    if allow_empty do
      result
    else
      message = Keyword.get(options, :parts, "input is not allowed to be empty")

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

  def check(result, _, _, _) do
    result
  end
end
