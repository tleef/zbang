defmodule Z.DateTime.Test do
  use ExUnit.Case, async: true

  alias Z.{Result, Error, Context, DateTime}

  describe "Z.DateTime.check(_, :parse, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2016-05-24 13:26:08Z])
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.value == ~U[2015-01-23 23:50:07Z]
    end

    test "given `true`, when some ISO 8601 string with offset, returns result with parsed UTC value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07.123+02:30")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.value == ~U[2015-01-23 21:20:07.123Z]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, false, Context.new("."))

      assert result.value == "2015-01-23T23:50:07Z"
    end

    test "given format :iso8601, when some ISO 8601 string, returns result with parsed value" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, :iso8601, Context.new("."))

      assert result.value == ~U[2015-01-23 23:50:07Z]
    end

    test "given invalid format, when some ISO 8601 string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07Z")
        |> DateTime.check(:parse, :invalid, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to parse DateTime with format: :invalid, format must be :iso8601",
               path: ["."]
             })
    end

    test "given `true`, when some invalid string, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value("2015-01-23T23:50:07")
        |> DateTime.check(:parse, true, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_string(),
               message: "unable to parse input as a DateTime",
               path: ["."]
             })
    end
  end

  describe "Z.DateTime.check(_, :allow_int, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:allow_int, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2016-05-24 13:26:08Z])
        |> DateTime.check(:allow_int, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some unix timestamp, returns result with converted value" do
      result =
        Result.new()
        |> Result.set_value(1_464_096_368)
        |> DateTime.check(:allow_int, true, Context.new("."))

      assert result.value == ~U[2016-05-24 13:26:08Z]
    end

    test "given :unix, when some unix timestamp, returns result with converted value" do
      result =
        Result.new()
        |> Result.set_value(1_464_096_368)
        |> DateTime.check(:allow_int, :unix, Context.new("."))

      assert result.value == ~U[2016-05-24 13:26:08Z]
    end

    test "given :unix, when some invalid unix timestamp, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(253_402_300_800)
        |> DateTime.check(:allow_int, :unix, Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_date(),
               message: "unable to convert unix input to a DateTime",
               path: ["."]
             })
    end

    test "given :gregorian, when some gregorian timestamp, returns result with converted value" do
      result =
        Result.new()
        |> Result.set_value(63_755_511_991)
        |> DateTime.check(:allow_int, :gregorian, Context.new("."))

      assert result.value == ~U[2020-05-01 00:26:31Z]
    end

    test "given `false`, when some value, returns result with original value" do
      result =
        Result.new()
        |> Result.set_value(1_464_096_368)
        |> DateTime.check(:allow_int, false, Context.new("."))

      assert result.value == 1_464_096_368
    end
  end

  describe "Z.DateTime.check(_, :type, _, _)/4" do
    test "given empty options, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when DateTime value, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31Z])
        |> DateTime.check(:type, [], Context.new("."))

      assert result.status == :valid
    end

    test "given empty options, when non-DateTime value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> DateTime.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a DateTime",
               path: ["."]
             })
    end

    test "given empty options, when NaiveDateTime value, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(~N[2000-01-01 23:00:07])
        |> DateTime.check(:type, [], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_type(),
               message: "input is not a DateTime",
               path: ["."]
             })
    end
  end

  describe "Z.DateTime.check(_, :shift, _, _)/4" do
    test "given Etc/UTC, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:shift, "Etc/UTC", Context.new("."))

      assert result.status == :valid
    end

    test "given Etc/UTC, when not a DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> DateTime.check(:shift, "Etc/UTC", Context.new("."))

      assert result.status == :valid
    end

    test "given Etc/UTC, when some DateTime with offset, returns result with shifted value" do
      result =
        Result.new()
        |> Result.set_value(%Elixir.DateTime{
          year: 2000,
          month: 2,
          day: 29,
          zone_abbr: "CET",
          hour: 23,
          minute: 0,
          second: 7,
          microsecond: {0, 0},
          utc_offset: 3600,
          std_offset: 0,
          time_zone: "Europe/Warsaw"
        })
        |> DateTime.check(:shift, "Etc/UTC", Context.new("."))

      assert result.value == ~U[2000-02-29 22:00:07Z]
    end

    test "given invalid timezone, when some DateTime, returns invalid result with error" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31Z])
        |> DateTime.check(:shift, "Europe/Warsaw", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "unable to shift input to \"Europe/Warsaw\" timezone",
               path: ["."]
             })
    end
  end

  describe "Z.DateTime.check(_, :trunc, _, _)/4" do
    test "given `true`, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when not a DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> DateTime.check(:trunc, true, Context.new("."))

      assert result.status == :valid
    end

    test "given `true`, when some DateTime, returns result with value truncated to seconds" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31.123456Z])
        |> DateTime.check(:trunc, true, Context.new("."))

      assert result.value == ~U[2020-05-01 00:26:31Z]
    end

    test "given :second, when some DateTime, returns result with value truncated to seconds" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31.123456Z])
        |> DateTime.check(:trunc, :second, Context.new("."))

      assert result.value == ~U[2020-05-01 00:26:31Z]
    end

    test "given :millisecond, when some DateTime, returns result with value truncated to milliseconds" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31.123456Z])
        |> DateTime.check(:trunc, :millisecond, Context.new("."))

      assert result.value == ~U[2020-05-01 00:26:31.123Z]
    end

    test "given :microsecond, when some DateTime, returns result with value truncated to microseconds" do
      result =
        Result.new()
        |> Result.set_value(~U[2020-05-01 00:26:31.123456789Z])
        |> DateTime.check(:trunc, :microsecond, Context.new("."))

      assert result.value == ~U[2020-05-01 00:26:31.123456Z]
    end
  end

  describe "Z.DateTime.check(_, :min, _, _)/4" do
    test "given min DateTime, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:min, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when not a DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> DateTime.check(:min, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when DateTime late enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2000-01-01 00:00:00Z])
        |> DateTime.check(:min, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when DateTime too early, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~U[1999-12-31 23:59:59Z])
        |> DateTime.check(:min, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_small(),
               message: "input is too early",
               path: ["."]
             })
    end

    test "given invalid min DateTime, when some DateTime, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~U[2000-01-01 00:00:00Z])
        |> DateTime.check(:min, "2000-01-01 00:00:00Z", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "min value must be a DateTime",
               path: ["."]
             })
    end
  end

  describe "Z.DateTime.check(_, :max, _, _)/4" do
    test "given min DateTime, when nil, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(nil)
        |> DateTime.check(:max, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when not a DateTime, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(123)
        |> DateTime.check(:max, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when DateTime early enough, returns valid result" do
      result =
        Result.new()
        |> Result.set_value(~U[2000-01-01 00:00:00Z])
        |> DateTime.check(:max, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :valid
    end

    test "given min DateTime, when DateTime too late, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~U[2000-01-01 00:00:01Z])
        |> DateTime.check(:max, ~U[2000-01-01 00:00:00Z], Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.too_big(),
               message: "input is too late",
               path: ["."]
             })
    end

    test "given invalid min DateTime, when some DateTime, returns invalid result with errors" do
      result =
        Result.new()
        |> Result.set_value(~U[2000-01-01 00:00:00Z])
        |> DateTime.check(:max, "2000-01-01T00:00:00Z", Context.new("."))

      assert result.status == :invalid

      assert Enum.member?(result.errors, %Error{
               code: Error.Codes.invalid_arguments(),
               message: "max value must be a DateTime",
               path: ["."]
             })
    end
  end

  describe "Z.DateTime.validate/3" do
    test "given some valid string, when :parse and other rules, set parsed value" do
      {:ok, ~U[2000-01-01 00:00:00Z]} = DateTime.validate("2000-01-01T00:00:00Z", [:parse])

      {:ok, ~U[2000-01-01 00:00:00Z]} =
        DateTime.validate("2000-01-01T00:00:00Z", [:required, :parse])

      {:ok, ~U[2000-01-01 00:00:00Z]} =
        DateTime.validate("2000-01-01T00:00:00Z", [
          :required,
          :parse,
          min: ~U[2000-01-01 00:00:00Z],
          max: ~U[2000-01-01 00:00:00Z]
        ])

      {:ok, ~U[2000-01-01 00:00:00Z]} =
        DateTime.validate("2000-01-01T00:00:00.123456Z", [
          :required,
          :parse,
          :trunc
        ])
    end

    test "given some valid int, when :allow_int, set converted value" do
      {:ok, ~U[2000-01-01 00:00:00Z]} = DateTime.validate(946_684_800, [:allow_int])
      {:ok, ~U[2000-01-01 00:00:00Z]} = DateTime.validate(63_113_904_000, allow_int: :gregorian)
    end

    test "given some valid DateTime, when :shift, set shifted value" do
      {:ok, ~U[2000-01-01 00:00:00Z]} =
        DateTime.validate(
          %Elixir.DateTime{
            year: 2000,
            month: 1,
            day: 1,
            zone_abbr: "CET",
            hour: 1,
            minute: 0,
            second: 0,
            microsecond: {0, 0},
            utc_offset: 3600,
            std_offset: 0,
            time_zone: "Europe/Warsaw"
          },
          shift: "Etc/UTC"
        )
    end
  end
end
