defmodule Dredd.Validators.List do
  @moduledoc false

  # TODO: 2022-12-27 - Think about renaming length parameters

  alias Dredd.{
    Dataset,
    ListErrors
  }

  @default_message %{
    type: "is not a list",
    is: "should have %{count} item(s)",
    min: "should have at least %{count} item(s)",
    max: "should have at most %{count} item(s)"
  }

  def call(%Dataset{valid?: false} = dataset, _validator, _opts) do
    dataset
  end

  def call(dataset, validator, opts) do
    dataset = Dredd.Dataset.new(dataset)
    value = dataset.data

    if is_list(value) do
      opts = Enum.into(opts, %{})

      case validate_length(value, opts) do
        :ok ->
          validate_elements(dataset, validator)

        {message, metadata} ->
          Dredd.set_single_error(dataset, message, :list, metadata)
      end
    else
      message = Keyword.get(opts, :type_message, @default_message.type)

      Dredd.set_single_error(dataset, message, :list, %{kind: :type})
    end
  end

  defp validate_length(value, opts) do
    value
    |> length()
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
    message = Map.get(opts, :max_message, @default_message.max)

    {message, %{count: count, kind: :max}}
  end

  defp check_length(_len, _opts) do
    :ok
  end

  defp validate_elements(dataset, validator) do
    list = dataset.data

    list_errors =
      list
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {value, idx}, list_errors ->
        result = validator.(value)

        if result.valid? do
          list_errors
        else
          Map.put(list_errors, idx, result.error)
        end
      end)

    if Enum.empty?(list_errors) do
      dataset
    else
      %Dataset{
        data: dataset.data,
        valid?: false,
        error: %ListErrors{
          errors: list_errors
        }
      }
    end
  end
end
