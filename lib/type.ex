defmodule Bliss.Type do
  @spec __using__(opts :: [options: [atom]]) :: any
  defmacro __using__(opts \\ []) do
    quote do
      @behaviour Bliss.Type

      def __type__ do
        __MODULE__
      end

      def __options__ do
        Keyword.get(unquote(opts), :options, [])
      end

      def validate(input, options \\ [], context \\ Bliss.Context.new()) do
        Bliss.Result.new() |> Bliss.Result.set_value(input) |> check(options, context)
      end

      def maybe_check(result, rule, options, context) do
        if Bliss.Rule.has_rule?(options, rule) do
          check(result, rule, Keyword.get(options, rule), context)
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
    :string => Bliss.String
  }

  def base?(type) when is_atom(type) do
    Map.has_key?(@base_types, type)
  end

  def get(type) when is_atom(type) do
    @base_types[type]
  end
end
