defmodule Dredd.Validators.NanoID do
  @moduledoc false

  @nanoid_regex ~r/^[\w-]+$/

  @default_message "is not a valid NanoID"
  @default_length 21

  def call(dataset, field, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = Map.get(dataset.data, field)

    message = Keyword.get(opts, :message, @default_message)
    length = Keyword.get(opts, :length, @default_length)

    if value == nil || is_nanoid?(value) do
      Dredd.validate_length(dataset, field, is: length, count: :bytes)
    else
      Dredd.add_error(dataset, field, message, validation: :nanoid)
    end
  end

  defp is_nanoid?(value) do
    if is_binary(value) do
      value =~ @nanoid_regex
    else
      false
    end
  end
end
