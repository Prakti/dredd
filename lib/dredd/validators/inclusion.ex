defmodule Dredd.Validators.Inclusion do
  @moduledoc false

  @default_message "is invalid"

  def call(dataset, enum, opts \\ [])

  def call(%Dredd.Dataset{valid?: false} = dataset, _enum, _opts) do
    dataset
  end

  def call(dataset, enum, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    if value == nil || value == "" || value in enum do
      dataset
    else
      Dredd.set_single_error(dataset, message, :inclusion, %{enum: enum})
    end
  end
end
