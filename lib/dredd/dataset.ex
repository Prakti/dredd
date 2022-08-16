defmodule Dredd.Dataset do
  @moduledoc """
  This is the internal datastructure in which the validators accumulate any validation errors.
  """

  defstruct data: %{}, errors: [], valid?: true

  @type error_t :: {String.t(), Keyword.t()}

  @type t :: %__MODULE__{
          data: map,
          errors: [{atom, error_t}],
          valid?: boolean
        }

  @spec new(map) :: t
  def new(%Dredd.Dataset{} = dataset), do: dataset
  def new(data), do: %__MODULE__{data: data}
end
