defmodule Dredd.Validators.List do
  @moduledoc false

  alias Dredd.{
    Dataset,
    ListErrors
  }

  def call(%Dataset{valid?: false} = dataset, _validator) do
    dataset
  end

  def call(dataset, validator) do
    dataset = Dredd.Dataset.new(dataset)
    enumerable_result = Dredd.validate_type(dataset.data, :list)

    if enumerable_result.valid? do
      list_errors = validate_elements(dataset.data, validator)

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
    else
      enumerable_result
    end
  end

  defp validate_elements(enumerable, validator) do
    enumerable
    |> Enum.with_index(fn element, index -> {index, element} end)
    |> Enum.reduce(%{}, fn {idx, value}, list_errors ->
      result = validator.(value)

      if result.valid? do
        list_errors
      else
        Map.put(list_errors, idx, result.error)
      end
    end)
  end
end
