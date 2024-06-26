defmodule Dredd.Validators.UUID do
  @moduledoc false

  @uuid_regex ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  @default_message "is not a valid uuid"

  def call(%Dredd.Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, _opts) do
    dataset = Dredd.Dataset.new(dataset)

    data = dataset.data

    if uuid?(data) do
      dataset
    else
      Dredd.set_single_error(dataset, @default_message, :uuid)
    end
  end

  defp uuid?(value) do
    if is_binary(value) do
      value =~ @uuid_regex
    else
      false
    end
  end
end
