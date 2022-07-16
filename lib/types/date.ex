defmodule Z.Date do
  @moduledoc """
  A module for validating a Date
  """

  alias Z.{Result, Error, Issue, Any}

  use Z.Type,
    options: Z.Any.__z__(:options) ++ [:parse, :trunc, :min, :max]

  def check(result, :conversions, rules, context) do
    result
    |> Any.check(:conversions, rules, context)
    |> maybe_check(:parse, rules, context)
    |> maybe_check(:trunc, rules, context)
  end

  def check(result, :mutations, rules, context) do
    result
    |> Any.check(:mutations, rules, context)
  end

  def check(result, :assertions, rules, context) do
    result
    |> Any.check(:assertions, rules, context)
    |> maybe_check(:min, rules, context)
    |> maybe_check(:max, rules, context)
  end

  def check(result, _rule, _options, _context) when result.value == nil do
    result
  end

  def check(result, :parse, _format, _context) when not is_binary(result.value) do
    result
  end

  def check(result, :parse, false, _context) do
    result
  end

  def check(result, :parse, true, context) do
    check(result, :parse, :iso8601, context)
  end

  def check(result, :parse, format, context) when format not in [:iso8601] do
    message = "unable to parse Date with format: #{inspect(format)}, format must be :iso8601"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :parse, _format, context) do
    case Date.from_iso8601(result.value) do
      {:ok, date} ->
        result |> Result.set_value(date)

      {:error, _} ->
        message = "unable to parse input as a Date"

        result
        |> Result.add_issue(
          Issue.new(
            Error.Codes.invalid_string(),
            message,
            context
          )
        )
    end
  end

  def check(result, :trunc, false, _context) do
    result
  end

  def check(result, :trunc, true, _context) when is_struct(result.value, DateTime) do
    result |> Result.set_value(result.value |> DateTime.to_date())
  end

  def check(result, :trunc, true, _context) when is_struct(result.value, NaiveDateTime) do
    result |> Result.set_value(result.value |> NaiveDateTime.to_date())
  end

  def check(result, :trunc, _enabled, _context) do
    result
  end

  def check(result, :type, options, context) when not is_struct(result.value, Date) do
    message = Keyword.get(options, :message, "input is not a Date")

    result
    |> Z.Result.add_issue(
      Z.Issue.new(
        Z.Error.Codes.invalid_type(),
        message,
        context
      )
    )
  end

  def check(result, :type, _options, _context) do
    result
  end

  def check(result, _rule, _options, _context) when not is_struct(result.value, Date) do
    result
  end

  def check(result, :min, {value, _options}, context) when not is_struct(value, Date) do
    message = "min value must be a Date"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :min, {value, options}, context) do
    case Date.compare(result.value, value) do
      :lt ->
        message = Keyword.get(options, :message, "input is too early")

        result
        |> Result.add_issue(
          Issue.new(
            Error.Codes.too_small(),
            message,
            context
          )
        )

      _ ->
        result
    end
  end

  def check(result, :min, value, context) do
    check(result, :min, {value, []}, context)
  end

  def check(result, :max, {value, _options}, context) when not is_struct(value, Date) do
    message = "max value must be a Date"

    result
    |> Result.add_issue(
      Issue.new(
        Error.Codes.invalid_arguments(),
        message,
        context
      )
    )
  end

  def check(result, :max, {value, options}, context) do
    case Date.compare(result.value, value) do
      :gt ->
        message = Keyword.get(options, :message, "input is too late")

        result
        |> Result.add_issue(
          Issue.new(
            Error.Codes.too_big(),
            message,
            context
          )
        )

      _ ->
        result
    end
  end

  def check(result, :max, value, context) do
    check(result, :max, {value, []}, context)
  end
end
