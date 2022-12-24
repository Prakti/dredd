defmodule Dredd.Validators.NanoID do
  @moduledoc false

  @nanoid_regex ~r/^[\w-]+$/

  @default_message "is not a valid NanoID"
  @default_length 21

  def call(%Dredd.Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)
    length = Keyword.get(opts, :length, @default_length)

    if value == nil || is_nanoid?(value) do
      Dredd.validate_length(value, is: length, count: :bytes)
    else
      Dredd.set_single_error(dataset, message, :nanoid)
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
