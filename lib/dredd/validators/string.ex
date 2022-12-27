defmodule Dredd.Validators.String do
  @moduledoc false

  alias Dredd.Dataset

  @default_message %{
    type: "is not a string",
    is: "should be %{count} character(s)",
    min: "should be at least %{count} character(s)",
    max: "should be at most %{count} character(s)"
  }

  # TODO: 2022-12-27 - Think about renaming length parameters

  def call(%Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dataset.new(dataset)
    value = dataset.data

    if String.valid?(value) do
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

  defp check_length(len, %{is: count} = opts) when len != count do
    message = Map.get(opts, :is_message, @default_message.is)

    {message, %{count: count, kind: :is}}
  end

  defp check_length(len, %{min: count} = opts) when len < count do
    message = Map.get(opts, :min_message, @default_message.min)

    {message, %{count: count, kind: :min}}
  end

  defp check_length(len, %{max: count} = opts) when len > count do
    message = Map.get(opts, :max_message, @default_message.max)

    {message, %{count: count, kind: :max}}
  end

  defp check_length(_len, _opts) do
    :ok
  end
end
