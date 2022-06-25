defmodule Bliss.Context do
  defstruct path: []

  @type t :: %Bliss.Context{
          path: [String.t()]
        }

  def new do
    %Bliss.Context{}
  end
end
