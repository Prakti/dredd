defmodule Dredd.MapErrors do
  @moduledoc """
  This datastructure shows for which fields in a struct validation failed.
  """

  defstruct validator: :map, errors: %{}

  @type error_t ::
          Dredd.SingleError.t()
          | Dredd.ListErrors.t()
          | Dredd.MapErrors.t()

  @type t :: %__MODULE__{
          validator: :map,
          errors: %{atom() => error_t}
        }
end
