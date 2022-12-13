defmodule Dredd.StructResult do
  @moduledoc """
  Represents the result of a struct-validator
  """

  defstruct data: %{}, valid?: true, errors: nil

  @type t :: %__MODULE__{
          data: struct() | map(),
          valid?: boolean(),
          errors: nil | Dredd.StructErrors.t()
        }

  @spec new(struct() | map() | t()) :: t()
  def new(%__MODULE__{} = result), do: result
  def new(data), do: %__MODULE__{data: data}
end
