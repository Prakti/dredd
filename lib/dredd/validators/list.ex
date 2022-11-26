defmodule Dredd.Validators.List do
  @moduledoc false

  @is_not_list_message "is not a list"

  def call(data, field, validator) do
    dataset = Dredd.Dataset.new(data)

    value = Map.get(dataset.data, field)

    if is_list(value) do
      indexed_list =
        value
        |> Enum.with_index(fn element, index -> {index, element} end)

      list_errors =
        indexed_list
        |> Enum.reduce(%{}, fn {idx, value}, list_errors ->
          fake_dataset = %{
            field: value
          }

          result = validator.(fake_dataset, :field)

          unless result.valid? do
            error = Keyword.get(result.errors, :field)
            Map.put(list_errors, idx, error)
          else
            list_errors
          end
        end)

      Dredd.add_error(dataset, field, Map.to_list(list_errors), validation: :list)
    else
      Dredd.add_error(dataset, field, @is_not_list_message, validation: :list)
    end
  end
end
