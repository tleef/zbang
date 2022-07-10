defmodule Bliss.Type do
  @spec __using__(opts :: [options: [atom]]) :: any
  defmacro __using__(opts \\ []) do
    options = Keyword.get(opts, :options, [])

    quote do
      @behaviour Bliss.Type

      def __bliss__(:type), do: __MODULE__
      def __bliss__(:options), do: unquote(options)

      def validate(input, rules \\ [], context \\ Bliss.Context.new(".")) do
        Bliss.Result.new()
        |> Bliss.Result.set_value(input)
        |> check(rules |> Bliss.Rule.to_keyword_list(), context)
        |> Bliss.Result.to_tuple()
      end

      def maybe_check(result, rule, rules, context) do
        if Keyword.has_key?(rules, rule) do
          check(result, rule, Keyword.fetch!(rules, rule), context)
        else
          result
        end
      end
    end
  end

  @typedoc "A Bliss type, primitive or custom."
  @type t :: primitive | custom

  @typedoc "Primitive Bliss types (handled by Bliss)."
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

  @callback check(Bliss.Result.t(), any, Bliss.Context.t()) :: Bliss.Result.t()
  @callback check(Bliss.Result.t(), atom, any, Bliss.Context.t()) :: Bliss.Result.t()

  @base_types %{
    :any => Bliss.Any,
    :atom => Bliss.Atom,
    :boolean => Bliss.Boolean,
    :interger => Bliss.Integer,
    :float => Bliss.Float,
    :string => Bliss.String,
    :list => Bliss.List
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
        if function_exported?(type, :__bliss__, 1) do
          {:ok, type}
        else
          {:error, :not_a_bliss_type}
        end

      true ->
        {:error, :unknown_type}
    end
  end
end
