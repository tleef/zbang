defmodule Bliss.Result do
  @moduledoc """
  The Result struct
  """

  defstruct status: :valid, value: nil, errors: []

  @type t :: %Bliss.Result{
          status: :valid | :invalid,
          value: any,
          errors: [Bliss.Error.t()]
        }

  def new do
    %Bliss.Result{}
  end

  def set_status(result, status) when status in [:valid, :invalid] do
    %{result | status: status}
  end

  def set_value(result, value) do
    %{result | value: value}
  end

  def add_error(result, error) do
    result = set_status(result, :invalid)
    %{result | errors: [error | result.errors]}
  end

  def add_errors(result, errors) do
    Enum.reduce(errors, result, fn err, res -> add_error(res, err) end)
  end

  def to_tuple(%Bliss.Result{status: :valid, value: value}) do
    {:ok, value}
  end

  def to_tuple(%Bliss.Result{status: :invalid, errors: errors}) do
    {:error, errors}
  end
end
