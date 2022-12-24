defmodule Dredd.Dataset do
  @moduledoc """
  This is the internal datastructure used for passing the current validation
  state from validator to validator including the top-level error-structure of any
  validated datastructure.
  """

  defstruct data: nil, error: nil, valid?: true

  @type error_t ::
          Dredd.SingleError.t()
          | Dredd.ListErrors.t()
          | Dredd.MapErrors.t()

  @type t :: %__MODULE__{
          data: any,
          error: nil | error_t,
          valid?: boolean
        }

  @spec new(map) :: t
  def new(%Dredd.Dataset{} = dataset), do: dataset
  def new(data), do: %__MODULE__{data: data}
end
