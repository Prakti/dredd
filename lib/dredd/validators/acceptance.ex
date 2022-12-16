defmodule Dredd.Validators.Acceptance do
  @moduledoc false

  @default_message "must be accepted"

  def call(dataset, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    case value do
      _valid when value in [true, nil] ->
        dataset

      _otherwise ->
        Dredd.set_single_error(dataset, message, :acceptance)
    end
  end
end
