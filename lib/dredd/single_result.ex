defmodule Dredd.SingleResult do
  @moduledoc """
  Represents the result of a single-value validator.
  """

  defstruct data: nil, valid?: true, error: nil

  @type t :: %__MODULE__{
          data: atom() | number() | binary(),
          valid?: boolean(),
          error: nil | Dredd.SingleError.t()
        }

  @spec new(atom() | number() | binary() | t()) :: t()
  def new(%__MODULE__{} = result), do: result
  def new(data), do: %__MODULE__{data: data}
end
