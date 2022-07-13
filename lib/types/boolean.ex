defmodule Bliss.Boolean do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options: Bliss.Any.__bliss__(:options) ++ [:parse]

  def check(result, rules, context) do
    result
    |> check(:conversions, rules, context)
    |> check(:type, rules, context)
    |> check(:mutations, rules, context)
    |> check(:assertions, rules, context)
  end

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
    |> maybe_check(:parse, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
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
    case String.upcase(result.value) do
      "TRUE" ->
        result |> Result.set_value(true)

      "FALSE" ->
        result |> Result.set_value(false)

      _ ->
        message = "unable to parse input as a boolean"

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

  def check(result, :type, options, context) when not is_boolean(result.value) do
    message = Keyword.get(options, :message, "input is not a boolean")

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
end
