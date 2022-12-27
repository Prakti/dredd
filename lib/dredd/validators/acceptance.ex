defmodule Dredd.Validators.Acceptance do
  @moduledoc false

  # TODO: 2022-12-27 - Move into boolean validator

  @default_message "must be accepted"

  def call(%Dredd.Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    if value == true do
      dataset
    else
      Dredd.set_single_error(dataset, message, :acceptance)
    end
  end
end
