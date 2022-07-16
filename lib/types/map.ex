defmodule Z.Map do
  @moduledoc """
  A module for validating a Map
  """

  alias Z.{Result, Error, Issue, Any}

  use Z.Type,
    options: Z.Any.__z__(:options) ++ [:atomize_keys, :size, :min, :max]

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
    |> maybe_check(:atomize_keys, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
    |> maybe_check(:size, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :type, options, context) when not is_map(result.value) do
    message = Keyword.get(options, :message, "input is not a Map")

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

  def check(result, _rule, _options, _context) when not is_map(result.value) do
    result
  end

  def check(result, :atomize_keys, _enabled, _context) when is_struct(result.value) do
    result
  end

  def check(result, :atomize_keys, false, _context) do
    result
  end

  def check(result, :atomize_keys, true, context) do
    check(result, :atomize_keys, :existing_only, context)
  end

  def check(result, :atomize_keys, mode, context)
      when mode not in [:existing_only, :dangerously_allow_non_existing] do
    message = "atomize_keys mode must be :existing_only or :dangerously_allow_non_existing"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :atomize_keys, :existing_only, context) do
    {kv_list, result} =
      Enum.map_reduce(result.value, result, fn kv, res ->
        key_to_existing_atom(kv, res, context)
      end)

    result |> Result.set_value(Map.new(kv_list))
  end

  def check(result, :atomize_keys, :dangerously_allow_non_existing, _context) do
    map =
      result.value
      |> Map.new(fn
        {k, v} when is_binary(k) -> {String.to_atom(k), v}
        {k, v} -> {k, v}
      end)

    result |> Result.set_value(map)
  end

  def check(result, :size, {size, _options}, context) when not is_integer(size) do
    message = "unable to check size with size: #{inspect(size)}, size must be an integer"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :size, {size, options}, context) when map_size(result.value) < size do
    message = Keyword.get(options, :message, "input does not have correct size")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_small(),
        message,
        context
      )
    )
  end

  def check(result, :size, {size, options}, context) when map_size(result.value) > size do
    message = Keyword.get(options, :message, "input does not have correct size")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_big(),
        message,
        context
      )
    )
  end

  def check(result, :size, {_size, _options}, _context) do
    result
  end

  def check(result, :size, size, context) do
    check(result, :size, {size, []}, context)
  end

  def check(result, :min, {size, _options}, context) when not is_integer(size) do
    message = "unable to check min size with size: #{inspect(size)}, size must be an integer"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :min, {size, options}, context) when map_size(result.value) < size do
    message = Keyword.get(options, :message, "input is too small")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_small(),
        message,
        context
      )
    )
  end

  def check(result, :min, {_size, _options}, _context) do
    result
  end

  def check(result, :min, size, context) do
    check(result, :min, {size, []}, context)
  end

  def check(result, :max, {size, _options}, context) when not is_integer(size) do
    message = "unable to check max size with size: #{inspect(size)}, size must be an integer"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :max, {size, options}, context) when map_size(result.value) > size do
    message = Keyword.get(options, :message, "input is too big")

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.too_big(),
        message,
        context
      )
    )
  end

  def check(result, :max, {_size, _options}, _context) do
    result
  end

  def check(result, :max, size, context) do
    check(result, :max, {size, []}, context)
  end

  defp key_to_existing_atom({k, v}, result, context) when is_binary(k) do
    try do
      a = String.to_existing_atom(k)
      {{a, v}, result}
    rescue
      _ ->
        message = "unable to atomize key"

        result =
          result
          |> Result.add_issue(
            Issue.new(
              Error.Codes.invalid_string(),
              message,
              Z.Context.new(k, context)
            )
          )

        {{k, v}, result}
    end
  end

  defp key_to_existing_atom({k, v}, result, _context) do
    {{k, v}, result}
  end
end
