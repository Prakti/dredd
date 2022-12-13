defmodule Dredd.SingleError do
  @moduledoc """
  Represents an error on a single Value.
  """

  defstruct validator: nil, message: "", metadata: %{}

  @type t :: %__MODULE__{
          validator: atom,
          message: binary(),
          metadata: map()
        }
end
