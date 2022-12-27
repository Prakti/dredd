defmodule Dredd.Validators.Boolean do
  @moduledoc false

  @default_messages %{
    wrong_type: "is not a boolean",
    wrong_value: "expected value: %{expected}"
  }

  alias Dredd.Dataset

  def call(%Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dataset.new(dataset)

    expected_value = Keyword.get(opts, :is, :undefined)

    check(dataset, opts, expected_value)
  end

  defp check(dataset, opts, :undefined) do
    value = dataset.data

    if is_boolean(value) do
      dataset
    else
      message = Keyword.get(opts, :wrong_type_message, @default_messages.wrong_type)
      Dredd.set_single_error(dataset, message, :boolean, %{kind: :type})
    end
  end

  defp check(dataset, opts, expected_value) do
    value = dataset.data

    if value == expected_value do
      dataset
    else
      message = Keyword.get(opts, :wrong_value_message, @default_messages.wrong_value)

      Dredd.set_single_error(dataset, message, :boolean, %{
        expected: expected_value,
        kind: :value
      })
    end
  end
end
