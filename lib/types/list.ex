defmodule Z.List do
  @moduledoc """
  A module for validating a List
  """

  alias Z.{Result, Error, Issue, Any}

  use Z.Type,
    options: Z.Any.__z__(:options) ++ [:length, :min, :max, :items]

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
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
    |> Result.add_issue(
      Issue.new(
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
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :length, {length, options}, context) when length(result.value) < length do
    message = Keyword.get(options, :message, "input does not have correct length")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_small(),
        message,
        context
      )
    )
  end

  def check(result, :length, {length, options}, context) when length(result.value) > length do
    message = Keyword.get(options, :message, "input does not have correct length")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_big(),
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
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :min, {length, options}, context) when length(result.value) < length do
    message = Keyword.get(options, :message, "input is too short")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_small(),
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
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :max, {length, options}, context) when length(result.value) > length do
    message = Keyword.get(options, :message, "input is too long")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_big(),
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

  def check(result, :items, {type, _rules}, context) when not is_atom(type) do
    message = "unable to check items of type: #{inspect(type)}, type must be an atom"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :items, {type, rules}, context) do
    case Z.Type.resolve(type) do
      {:ok, type} ->
        check_items(result, type, rules, context)

      _ ->
        message = "unable to check items of type: #{inspect(type)}, unknown type"

        result
        |> Result.add_issue(
          Issue.new(
            Error.Codes.invalid_arguments(),
            message,
            context
          )
        )
    end
  end

  def check(result, :items, type, context) do
    check(result, :items, {type, []}, context)
  end

  defp check_items(result, type, rules, context) do
    {list, result} =
      result.value
      |> with_indices()
      |> Enum.map_reduce(result, fn {item, index}, res ->
        check_item(res, item, index, type, rules, context)
      end)

    result
    |> Result.set_value(list)
  end

  defp check_item(result, item, index, type, rules, context) do
    case type.validate(item, rules, Z.Context.new(type, index, context)) do
      {:ok, value} ->
        {value, result}

      {:error, error} ->
        {item, result |> Result.add_issues(error.issues)}
    end
  end

  defp with_indices(list) do
    {list, _} = Enum.map_reduce(list, 0, fn item, index -> {{item, index}, index + 1} end)
    list
  end
end
