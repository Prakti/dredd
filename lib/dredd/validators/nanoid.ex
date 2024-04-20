defmodule Dredd.Validators.NanoID do
  @moduledoc false

  @nanoid_regex ~r/^[\w-]+$/

  @default_message %{
    type: "is not a valid NanoID",
    length: "expected NanoID length is %{count}"
  }
  @default_length 21

  def call(%Dredd.Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    length = Keyword.get(opts, :length, @default_length)

    if nanoid?(value) do
      if String.length(value) == length do
        dataset
      else
        message = Keyword.get(opts, :length_message, @default_message.length)

        Dredd.set_single_error(dataset, message, :nanoid, %{kind: :length, count: length})
      end
    else
      message = Keyword.get(opts, :type_message, @default_message.type)

      Dredd.set_single_error(dataset, message, :nanoid, %{kind: :type})
    end
  end

  defp nanoid?(value) do
    if is_binary(value) do
      value =~ @nanoid_regex
    else
      false
    end
  end
end
