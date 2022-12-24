defmodule Dredd.Validators.Exclusion do
  @moduledoc false

  @default_message "is reserved"

  def call(%Dredd.Dataset{valid?: false} = dataset, _enum, _opts) do
    dataset
  end

  def call(dataset, enum, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    if value in enum do
      Dredd.set_single_error(dataset, message, :exclusion, %{enum: enum})
    else
      dataset
    end
  end
end
