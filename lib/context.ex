defmodule Bliss.Context do
  defstruct parent: nil, path: ["."]

  @type t :: %Bliss.Context{
          parent: Bliss.Context.t(),
          path: [String.t()]
        }

  def new(path_segment, parent \\ nil) do
    %Bliss.Context{
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
