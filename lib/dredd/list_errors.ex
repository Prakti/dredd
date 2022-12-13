defmodule Dredd.ListErrors do
  @moduledoc """
  This datastructure shows where in a list validations failed.
  """

  defstruct validator: :list, errors: %{}

  @type error_t ::
          Dredd.SingleError.t()
          | Dredd.ListErrors.t()
          | Dredd.StructErrors.t()

  @type t :: %__MODULE__{
          validator: :list,
          errors: %{integer() => error_t}
        }
end
