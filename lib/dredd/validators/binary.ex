defmodule Dredd.Validators.Binary do
  @moduledoc false

  alias Dredd.Dataset

  @default_message %{
    type: "is not a binary",
    exact_length: "should be %{count} byte(s)",
    min_length: "should be at least %{count} byte(s)",
    max_length: "should be at most %{count} byte(s)"
  }

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

  defp check_length(len, %{exact_length: count} = opts) when len != count do
    message = Map.get(opts, :exact_length_message, @default_message.exact_length)

    {message, %{count: count, kind: :exact_length}}
  end

  defp check_length(len, %{min_length: count} = opts) when len < count do
    message = Map.get(opts, :min_length_message, @default_message.min_length)

    {message, %{count: count, kind: :min_length}}
  end

  defp check_length(len, %{max_length: count} = opts) when len > count do
    message = Map.get(opts, :max_length_message, @default_message.max_length)

    {message, %{count: count, kind: :max_length}}
  end

  defp check_length(_len, _opts) do
    :ok
  end
end
