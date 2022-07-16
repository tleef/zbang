defmodule Z.Type do
  @moduledoc """
  A module for defining Z types
  """

  @spec __using__(opts :: [options: [atom]]) :: any
  defmacro __using__(opts \\ []) do
    options = Keyword.get(opts, :options, [])

    quote do
      @behaviour Z.Type

      def __z__(:type), do: __MODULE__
      def __z__(:options), do: unquote(options)

      def validate(input, rules \\ [], context \\ Z.Context.new(".")) do
        Z.Result.new()
        |> Z.Result.set_value(input)
        |> check(rules |> Z.Rule.to_keyword_list(), context)
        |> Z.Result.to_tuple()
      end

      def validate!(input, rules \\ [], context \\ Z.Context.new(".")) do
        case validate(input, rules, context) do
          {:ok, value} -> value
          {:error, error} -> raise(error)
        end
      end

      defp check(result, rules, context) do
        result
        |> check(:conversions, rules, context)
        |> check(:type, rules, context)
        |> check(:mutations, rules, context)
        |> check(:assertions, rules, context)
      end

      defp maybe_check(result, rule, rules, context) do
        if Keyword.has_key?(rules, rule) do
          check(result, rule, Keyword.fetch!(rules, rule), context)
        else
          result
        end
      end
    end
  end

  @typedoc "A Z type, primitive or custom."
  @type t :: primitive | custom

  @typedoc "Primitive Z types (handled by Z)."
  @type primitive ::
          :any
          | :atom
          | :boolean
          | :integer
          | :float
          | :string
          | :map
          | :list
          | :datetime
          | :date
          | :time

  @typedoc "Custom types are represented by user-defined modules."
  @type custom :: module

  @callback check(Z.Result.t(), atom, any, Z.Context.t()) :: Z.Result.t()

  @base_types %{
    :any => Z.Any,
    :atom => Z.Atom,
    :boolean => Z.Boolean,
    :integer => Z.Integer,
    :float => Z.Float,
    :string => Z.String,
    :map => Z.Map,
    :list => Z.List,
    :datetime => Z.DateTime,
    :date => Z.Date,
    :time => Z.Time
  }

  def base?(type) when is_atom(type) do
    Map.has_key?(@base_types, type)
  end

  def get(type) when is_atom(type) do
    @base_types[type]
  end

  def resolve(type) when not is_atom(type) do
    {:error, :not_an_atom}
  end

  def resolve(type) do
    cond do
      base?(type) ->
        {:ok, get(type)}

      Code.ensure_compiled(type) == {:module, type} ->
        if function_exported?(type, :__z__, 1) do
          {:ok, type}
        else
          {:error, :not_a_z_type}
        end

      true ->
        {:error, :unknown_type}
    end
  end
end
