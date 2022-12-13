defmodule Dredd.StructErrors do
  @moduledoc """
  This datastructure shows for which fields in a struct validation failed.
  """

  defstruct validator: :struct, errors: %{}

  @type error_t ::
          Dredd.SingleError.t()
          | Dredd.ListErrors.t()
          | Dredd.StructErrors.t()

  @type t :: %__MODULE__{
          validator: :struct,
          errors: %{atom() => error_t}
        }
end
