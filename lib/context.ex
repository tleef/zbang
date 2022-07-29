defmodule Z.Context do
  @moduledoc """
  The Context struct
  """

  defstruct parent: nil, type: nil, path: ["."]

  @type t :: %Z.Context{
          parent: Z.Context.t(),
          type: atom(),
          path: [String.t()]
        }

  def new(type \\ nil, path_segment \\ ".", parent \\ nil) do
    %Z.Context{
      parent: parent,
      type: type,
      path: path(path_segment, parent)
    }
  end

  defp path(path_segment, nil) do
    [path_segment]
  end

  defp path(path_segment, parent) do
    [path_segment | parent.path]
  end
end
