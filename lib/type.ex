defmodule Bliss.Type do
  defmacro __using__(_opts) do
    quote do
      def get_flag_options(options, flag) do
        Keyword.get(options, flag, Enum.member?(options, flag))
      end

      def maybe_check(result, rule, options, context) do
        if Enum.member?(options, rule) || Keyword.has_key?(options, rule) do
          check(result, rule, Keyword.get(options, rule), context)
        else
          result
        end
      end
    end
  end
end
