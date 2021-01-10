defmodule Bliss.Validators.Any.Test do
  use ExUnit.Case, async: true

  alias Bliss.Validators.Any

  describe "Bliss.Validators.Any.validate/4" do
    test "nil value with no default returns nil" do
      {:ok, value} = Any.validate(nil, [])
      assert value == nil
    end

    test "non-nil value with no default returns value" do
      {:ok, value} = Any.validate(123, [])
      assert value == 123
    end

    test "nil value with default returns default" do
      {:ok, value} = Any.validate(nil, default: 123)
      assert value == 123
    end

    test "non-nil value with default returns value" do
      {:ok, value} = Any.validate(false, default: 123)
      assert value == false
    end

    test "allowed value returns value" do
      {:ok, value} = Any.validate("good", allow: ["good"])
      assert value == "good"
    end

    test "non-allowed value returns value" do
      {:ok, value} = Any.validate("other", allow: ["good"])
      assert value == "other"
    end

    test "valid value returns value" do
      {:ok, value} = Any.validate("good", valid: ["good"])
      assert value == "good"
    end

    test "non-valid value returns error" do
      {:error, error} = Any.validate("bad", valid: ["good"])
      assert error.message == "`value` must be one of [\"good\"]"
    end

    test "invalid value returns error" do
      {:error, error} = Any.validate("bad", invalid: ["bad"])
      assert error.message == "`value` contains an invalid value"
    end

    test "non-invalid value returns value" do
      {:ok, value} = Any.validate("good", invalid: ["bad"])
      assert value == "good"
    end

    test "optional value returns value" do
      {:ok, value} = Any.validate("good", optional: true)
      assert value == "good"
    end

    test "optional nil value returns nil" do
      {:ok, value} = Any.validate(nil, optional: true)
      assert value == nil
    end

    test "non-optional value returns value" do
      {:ok, value} = Any.validate("good", optional: false)
      assert value == "good"
    end

    test "non-optional nil value returns error" do
      {:error, error} = Any.validate(nil, optional: false)
      assert error.message == "`value` is required"
    end

    test "required value returns value" do
      {:ok, value} = Any.validate("good", required: true)
      assert value == "good"
    end

    test "required nil value returns error" do
      {:error, error} = Any.validate(nil, required: true)
      assert error.message == "`value` is required"
    end

    test "non-required value returns value" do
      {:ok, value} = Any.validate("good", required: false)
      assert value == "good"
    end

    test "non-required nil value returns nil" do
      {:ok, value} = Any.validate(nil, required: false)
      assert value == nil
    end
  end
end
