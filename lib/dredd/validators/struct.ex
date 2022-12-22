defmodule Dredd.Validators.Struct do
  @moduledoc false

  alias Dredd.{
    Dataset,
    StructErrors,
  }

  def call(%Dataset{valid?: false} = dataset, _validator_map) do
    dataset
  end

  def call(dataset, validator_map) do
    dataset = Dredd.Dataset.new(dataset)
    struct_result = Dredd.validate_type(dataset.data, :struct)

    if struct_result.valid? do
      struct_errors = validate(dataset.data, validator_map)

      if Enum.empty?(struct_errors)do
        dataset
      else 
        %Dataset{
          data: dataset.data,
          valid?: false,
          error: %StructErrors{
            errors: struct_errors
          }
        }
      end
    else
      struct_result
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
