defmodule Dredd.Validators.Exclusion do
  @moduledoc false

  @default_message "is reserved"

  def call(dataset, field, enum, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = Map.get(dataset.data, field)

    message = Keyword.get(opts, :message, @default_message)

    if value in enum do
      Dredd.add_error(dataset, field, message, validation: :exclusion, enum: enum)
    else
      dataset
    end
  end
end
