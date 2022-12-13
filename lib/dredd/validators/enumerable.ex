defmodule Dredd.Validators.Enumerable do
  @moduledoc false

  @default_message "is not enumerable"
  
  use Dredd.SingleValidator

  # TODO: 2022-12-12 Write Test for Enumerable Validator

  @impl true
  def validate(result, _opts) do
    if Enumerable.impl_for(result.data) != nil do
      result
    else
      error_result(result.data, @default_message, :enumerable, %{}) 
    end
  end

end
