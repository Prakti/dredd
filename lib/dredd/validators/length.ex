defmodule Dredd.Validators.Length do
  @moduledoc false

  @default_message %{
    string: %{
      is: "should be %{count} character(s)",
      min: "should be at least %{count} character(s)",
      max: "should be at most %{count} character(s)"
    },
    binary: %{
      is: "should be %{count} byte(s)",
      min: "should be at least %{count} byte(s)",
      max: "should be at most %{count} byte(s)"
    },
    list: %{
      is: "should have %{count} item(s)",
      min: "should have at least %{count} item(s)",
      max: "should have at most %{count} item(s)"
    }
  }

  def call(dataset, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    opts =
      opts
      |> Keyword.put_new(:count, :graphemes)
      |> Enum.into(%{})

    case validate(value, opts) do
      :ok ->
        dataset

      {message, validator, metadata} ->
        Dredd.set_single_error(dataset, message, validator, metadata)
    end
  end

  #
  # private
  #

  defp validate("", _opts) do
    :ok
  end

  defp validate(value, %{count: :codepoints} = opts) when is_binary(value) do
    check(:string, length(String.codepoints(value)), opts)
  end

  defp validate(value, %{count: :graphemes} = opts) when is_binary(value) do
    check(:string, length(String.graphemes(value)), opts)
  end

  defp validate(value, %{count: :bytes} = opts) when is_binary(value) do
    check(:binary, byte_size(value), opts)
  end

  defp validate(value, opts) when is_list(value) do
    check(:list, length(value), opts)
  end

  defp validate(_value, _opts) do
    :ok
  end

  defp check(type, len, %{is: count} = opts) when len != count do
    message = Map.get(opts, :message, get_in(@default_message, [type, :is]))

    {message, :length, %{count: count, kind: :is, type: type}}
  end

  defp check(type, len, %{min: count} = opts) when len < count do
    message = Map.get(opts, :message, get_in(@default_message, [type, :min]))

    {message, :length, %{count: count, kind: :min, type: type}}
  end

  defp check(type, len, %{max: count} = opts) when len > count do
    message = Map.get(opts, :message, get_in(@default_message, [type, :max]))

    {message, :length, %{count: count, kind: :max, type: type}}
  end

  defp check(_type, _len, _opts) do
    :ok
  end
end
