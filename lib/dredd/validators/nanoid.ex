defmodule Dredd.Validators.NanoID do
  @moduledoc false

  @nanoid_regex ~r/^[\w-]+$/

  @default_message %{
    type: "is not a valid NanoID",
    length: "expected nanoID length %{count}",
  }
  @default_length 21

  def call(%Dredd.Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    length = Keyword.get(opts, :length, @default_length)

    if is_nanoid?(value) do
      if String.length(value) == length do
        dataset
      else 
        message = Keyword.get(opts, :message, @default_message.length)

        Dredd.set_single_error(dataset, message, :nanoid)
      end
    else
      message = Keyword.get(opts, :message, @default_message.type)

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
