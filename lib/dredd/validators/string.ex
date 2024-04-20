defmodule Dredd.Validators.String do
  @moduledoc false

  alias Dredd.Dataset

  @default_message %{
    type: "is not a string",
    exact_length: "should be %{count} character(s)",
    min_length: "should be at least %{count} character(s)",
    max_length: "should be at most %{count} character(s)"
  }

  def call(%Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dataset.new(dataset)
    value = dataset.data

    if is_binary(value) && String.valid?(value) do
      opts =
        opts
        |> Keyword.put_new(:count, :graphemes)
        |> Enum.into(%{})

      case validate_length(value, opts) do
        :ok ->
          dataset

        {message, metadata} ->
          Dredd.set_single_error(dataset, message, :string, metadata)
      end
    else
      message = Keyword.get(opts, :type_message, @default_message.type)

      Dredd.set_single_error(dataset, message, :string, %{kind: :type})
    end
  end

  defp validate_length(value, %{count: :codepoints} = opts) do
    value
    |> check_trim(opts)
    |> String.codepoints()
    |> length
    |> check_length(opts)
  end

  defp validate_length(value, %{count: :graphemes} = opts) do
    value
    |> check_trim(opts)
    |> String.length()
    |> check_length(opts)
  end

  defp check_trim(value, %{trim?: false}), do: value

  defp check_trim(value, _), do: String.trim(value)

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
