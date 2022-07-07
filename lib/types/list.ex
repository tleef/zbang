defmodule Bliss.List do
  alias Bliss.{Result, Error, Any}

  use Bliss.Type,
    options: Bliss.Any.__bliss__(:options) ++ [:length, :min, :max, :items]

  def check(result, rules, context) do
    result
    |> Any.check(rules, context)
    |> check(:type, rules, context)
    |> maybe_check(:length, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
    |> maybe_check(:items, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :type, options, context) when not is_list(result.value) do
    message = Keyword.get(options, :message, "input is not a list")

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

  def check(result, _rule, _options, _context) when not is_list(result.value) do
    result
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

  def check(result, :length, {length, options}, context) when length(result.value) != length do
    message = Keyword.get(options, :message, "input does not have correct length")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_string(),
        message,
        context
      )
    )
  end

  def check(result, :length, {_length, _options}, _context) do
    result
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

  def check(result, :min, {length, options}, context) when length(result.value) < length do
    message = Keyword.get(options, :message, "input is too short")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_string(),
        message,
        context
      )
    )
  end

  def check(result, :min, {_length, _options}, _context) do
    result
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

  def check(result, :max, {length, options}, context) when length(result.value) > length do
    message = Keyword.get(options, :message, "input is too long")

    result
    |> Result.add_error(
      Error.new(
        Error.Codes.invalid_string(),
        message,
        context
      )
    )
  end

  def check(result, :max, {_length, _options}, _context) do
    result
  end

  def check(result, :max, length, context) do
    check(result, :max, {length, []}, context)
  end

  def check(result, :items, {type, rules}, context) do
    {list, result} =
      Enum.map_reduce(result.value, result, fn item, res ->
        check_item(res, item, type, rules, context)
      end)

    result
    |> Result.set_value(list)
  end

  def check_item(result, item, type, rules, context) do
    case type.validate(item, rules, Bliss.Context.new("index", context)) do
      {:ok, value} ->
        {value, result}

      {:error, errors} ->
        {item, result |> Result.add_errors(errors)}
    end
  end
end