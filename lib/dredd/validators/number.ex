defmodule Dredd.Validators.Number do
  @moduledoc false

  # TODO: 2022-12-27 - Support valure ranges

  @available_types [
    :float,
    :integer,
    :non_neg_integer,
    :pos_integer,
  ]

  @default_message "is not a number"

  def call(%Dredd.Dataset{valid?: false} = dataset, _type, _opts) do
    dataset
  end

  def call(dataset, type, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    validate(dataset, type, value, opts)
  end

  defp validate(dataset, type, value, opts) do
    if check(type, value) do
      dataset
    else
      message = Keyword.get(opts, :message, @default_message)

      Dredd.set_single_error(dataset, message, :number, %{kind: type})
    end
  end

  defp check(:float, value) do
    is_float(value)
  end

  defp check(:integer, value) do
    is_integer(value)
  end

  defp check(:non_neg_integer, value) do
    is_integer(value) && value >= 0
  end

  defp check(:pos_integer, value) do
    is_integer(value) && value > 0
  end

  defp check(type, _value) do
    available_types = Enum.map_join(@available_types, ", ", &inspect/1)

    raise ArgumentError,
          "unknown number #{inspect(type)} given to Dredd.validate_number/3.\n\n Available types: #{available_types}"
  end
end