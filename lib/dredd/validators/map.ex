defmodule Dredd.Validators.Map do
  @moduledoc false

  alias Dredd.{
    Dataset,
    MapErrors,
  }

  def call(%Dataset{valid?: false} = dataset, _validator_map) do
    dataset
  end

  def call(dataset, validator_map) do
    dataset = Dredd.Dataset.new(dataset)
    type_result = Dredd.validate_type(dataset.data, :map)

    if type_result.valid? do
      map_errors = validate(dataset.data, validator_map)

      if Enum.empty?(map_errors)do
        dataset
      else 
        %Dataset{
          data: dataset.data,
          valid?: false,
          error: %MapErrors{
            errors: map_errors
          }
        }
      end
    else
      type_result
    end
  end

  defp validate(data, validator_map) do
    validator_map
    |> Enum.reduce(%{}, fn {fieldname, validator}, error_map -> 
      value = Access.get(data, fieldname, nil)

      result = validator.(value)

      if result.valid? do
        error_map
      else
        Map.put(error_map, fieldname, result.error)
      end
    end)
  end
end
