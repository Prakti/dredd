defmodule Dredd.Validators.List do
  @moduledoc false

  alias Dredd.{
    Dataset,
    ListErrors
  }

  @default_message %{
    type: "is not a list",
    exact_length: "should have %{count} item(s)",
    min_length: "should have at least %{count} item(s)",
    max_length: "should have at most %{count} item(s)"
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
