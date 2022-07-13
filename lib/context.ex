defmodule Z.Context do
  @moduledoc """
  The Context struct
  """

  defstruct parent: nil, path: ["."]

  @type t :: %Z.Context{
          parent: Z.Context.t(),
          path: [String.t()]
        }

  def new(path_segment, parent \\ nil) do
    %Z.Context{
      parent: parent,
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
