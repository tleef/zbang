defmodule Bliss.Result do
  defstruct status: :valid, value: nil, errors: []

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
end
