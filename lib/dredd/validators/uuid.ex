defmodule Dredd.Validators.UUID do
  @moduledoc false

  @uuid_regex ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  @default_message "is not a valid uuid"

  def call(dataset, field, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = Map.get(dataset.data, field)

    message = Keyword.get(opts, :message, @default_message)

    if value == nil || is_uuid?(value) do
      dataset
    else
      Dredd.add_error(dataset, field, message, validation: :uuid)
    end
  end

  defp is_uuid?(value) do
    if is_binary(value) do
      value =~ @uuid_regex
    else
      false
    end
  end
end
