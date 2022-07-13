defmodule Bliss.Error do
  @moduledoc """
  The Error struct
  """

  defstruct [:code, :message, :path]

  @type t :: %Bliss.Error{
          code: String.t(),
          message: String.t(),
          path: [String.t()]
        }

  def new(code, message, context) do
    %Bliss.Error{
      code: code,
      message: message,
      path: context.path |> Enum.reverse()
    }
  end

  defmodule Codes do
    @moduledoc """
    Static error codes
    """

    @invalid_type "invalid_type"
    @invalid_literal "invalid_literal"
    @custom "custom"
    @invalid_union "invalid_union"
    @invalid_union_discriminator "invalid_union_discriminator"
    @invalid_enum_value "invalid_enum_value"
    @unrecognized_keys "unrecognized_keys"
    @invalid_arguments "invalid_arguments"
    @invalid_return_type "invalid_return_type"
    @invalid_date "invalid_date"
    @invalid_string "invalid_string"
    @too_small "too_small"
    @too_big "too_big"
    @invalid_intersection_types "invalid_intersection_types"
    @not_multiple_of "not_multiple_of"

    def invalid_type, do: @invalid_type
    def invalid_literal, do: @invalid_literal
    def custom, do: @custom
    def invalid_union, do: @invalid_union
    def invalid_union_discriminator, do: @invalid_union_discriminator
    def invalid_enum_value, do: @invalid_enum_value
    def unrecognized_keys, do: @unrecognized_keys
    def invalid_arguments, do: @invalid_arguments
    def invalid_return_type, do: @invalid_return_type
    def invalid_date, do: @invalid_date
    def invalid_string, do: @invalid_string
    def too_small, do: @too_small
    def too_big, do: @too_big
    def invalid_intersection_types, do: @invalid_intersection_types
    def not_multiple_of, do: @not_multiple_of
  end
end
