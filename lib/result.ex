defmodule Z.Result do
  @moduledoc """
  The Result struct
  """

  defstruct status: :valid, value: nil, issues: []

  @type t :: %Z.Result{
          status: :valid | :invalid,
          value: any,
          issues: [Z.Issue.t()]
        }

  def new do
    %Z.Result{}
  end

  def set_status(result, status) when status in [:valid, :invalid] do
    %{result | status: status}
  end

  def set_value(result, value) do
    %{result | value: value}
  end

  def add_issue(result, issue) do
    result = set_status(result, :invalid)
    %{result | issues: [issue | result.issues]}
  end

  def add_issues(result, issues) do
    Enum.reduce(issues, result, fn err, res -> add_issue(res, err) end)
  end

  def to_tuple(%Z.Result{status: :valid, value: value}) do
    {:ok, value}
  end

  def to_tuple(%Z.Result{status: :invalid, issues: issues}) do
    {:error, %Z.Error{issues: issues}}
  end
end
