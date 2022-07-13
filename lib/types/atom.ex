defmodule Bliss.Atom do
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
    check(result, :parse, :existing_only, context)
  end

  def check(result, :parse, mode, context)
      when mode not in [:existing_only, :dangerously_allow_non_existing] do
    message = "parse mode must be :existing_only or :dangerously_allow_non_existing"

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :parse, :existing_only, context) do
    try do
      a = String.to_existing_atom(result.value)

      result
      |> Result.set_value(a)
    rescue
      _ ->
        message = "unable to parse input as an atom"

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

  def check(result, :parse, :dangerously_allow_non_existing, _context) do
    result |> Result.set_value(String.to_atom(result.value))
  end

  def check(result, :type, options, context) when not is_atom(result.value) do
    message = Keyword.get(options, :message, "input is not an atom")

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
