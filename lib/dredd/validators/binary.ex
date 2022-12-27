defmodule Dredd.Validators.Binary do
  @moduledoc false

  alias Dredd.Dataset

  @default_message %{
    type: "is not a binary",
    is: "should be %{count} byte(s)",
    min: "should be at least %{count} byte(s)",
    max: "should be at most %{count} byte(s)"
  }

  # TODO: 2022-12-27 - Think about renaming length parameters

  def call(%Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dataset.new(dataset)
    value = dataset.data

    if is_binary(value) do
      opts = Enum.into(opts, %{})

      case validate_length(value, opts) do
        :ok ->
          dataset

        {message, metadata} ->
          Dredd.set_single_error(dataset, message, :binary, metadata)
      end
    else
      message = Keyword.get(opts, :type_message, @default_message.type)

      Dredd.set_single_error(dataset, message, :binary, %{kind: :type})
    end
  end

  defp validate_length(value, opts) do
    value
    |> byte_size()
    |> check_length(opts)
  end

  defp check_length(len, %{is: count} = opts) when len != count do
    message = Map.get(opts, :is_message, @default_message.is)

    {message, %{count: count, kind: :is}}
  end

  defp check_length(len, %{min: count} = opts) when len < count do
    message = Map.get(opts, :min_message, @default_message.min)

    {message, %{count: count, kind: :min}}
  end

  defp check_length(len, %{max: count} = opts) when len > count do
    message = Map.get(opts, :message, @default_message.max)

    {message, %{count: count, kind: :max}}
  end

  defp check_length(_len, _opts) do
    :ok
  end
end
