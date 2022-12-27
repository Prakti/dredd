defmodule Dredd.Validators.Number do
  @moduledoc false

  @available_types [
    :float,
    :integer,
    :non_neg_integer,
    :pos_integer
  ]

  @default_message %{
    type: "has incorrect numerical type",
    predicate: "violates the given predicate"
  }

  def call(%Dredd.Dataset{valid?: false} = dataset, _type, _opts) do
    dataset
  end

  def call(dataset, type, opts) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    validate(dataset, type, value, opts)
  end

  defp validate(dataset, type, value, opts) do
    if check_type(type, value) do
      predicate = Keyword.get(opts, :predicate, &accept_all/1)

      if predicate.(value) do
        dataset
      else
        message = Keyword.get(opts, :predicate_message, @default_message.predicate)

        Dredd.set_single_error(dataset, message, :number, %{kind: :predicate})
      end
    else
      message = Keyword.get(opts, :type_message, @default_message.type)

      Dredd.set_single_error(dataset, message, :number, %{kind: type})
    end
  end

  defp check_type(:float, value) do
    is_float(value)
  end

  defp check_type(:integer, value) do
    is_integer(value)
  end

  defp check_type(:non_neg_integer, value) do
    is_integer(value) && value >= 0
  end

  defp check_type(:pos_integer, value) do
    is_integer(value) && value > 0
  end

  defp check_type(type, _value) do
    available_types = Enum.map_join(@available_types, ", ", &inspect/1)

    raise ArgumentError,
          "unknown number #{inspect(type)} given to Dredd.validate_number/3.\n\n Available types: #{available_types}"
  end

  defp accept_all(_), do: true
end
