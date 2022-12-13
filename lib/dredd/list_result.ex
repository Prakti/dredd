defmodule Dredd.ListResult do
  @moduledoc """
  Represents the result of a list-validator.
  """

  defstruct data: [], valid?: true, error: nil

  @type t :: %__MODULE__{
          data: list(),
          valid?: boolean(),
          error: nil | Dredd.ListErrors.t()
        }

  @spec new(list() | t()) :: t()
  def new(%__MODULE__{} = result), do: result
  def new(data), do: %__MODULE__{data: data}
end
