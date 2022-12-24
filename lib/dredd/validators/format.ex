defmodule Dredd.Validators.Format do
  @moduledoc false

  @default_message "has invalid format"

  def call(%Dredd.Dataset{valid?: false} = dataset, _format, _opts) do
    dataset
  end

  def call(dataset, format, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    if value == nil || value == "" || value =~ format do
      dataset
    else
      Dredd.set_single_error(dataset, message, :format)
    end
  end
end
