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

  @typedoc "A Blis type, primitive or custom."
  @type t :: primitive | custom

  @typedoc "Primitive Bliss types (handled by Bliss)."
  @type primitive ::
          :integer
          | :float
          | :boolean
          | :string
          | :map
          | :array
          | :any
          | :datetime
          | :date
          | :time

  @typedoc "Custom types are represented by user-defined modules."
  @type custom :: module

  @callback check(Bliss.Result.t(), any, Bliss.Context.t()) :: Bliss.Result.t()
  @callback check(Bliss.Result.t(), atom, any, Bliss.Context.t()) :: Bliss.Result.t()

  @base_types %{
    :string => Bliss.String,
    :any => Bliss.Any
  }

  def base?(type) when is_atom(type) do
    Map.has_key?(@base_types, type)
  end

  def get(type) when is_atom(type) do
    @base_types[type]
  end
end
