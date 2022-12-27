defmodule Dredd.Validators.Map do
  @moduledoc false

  alias Dredd.{
    Dataset,
    MapErrors
  }

  def call(%Dataset{valid?: false} = dataset, _validator_map) do
    dataset
  end

  def call(dataset, validator_map) do
    dataset = Dredd.Dataset.new(dataset)
    type_result = Dredd.validate_type(dataset.data, :map)

    if type_result.valid? do
      data = dataset.data

      {_, error_map} = Enum.reduce(validator_map, {data, %{}}, &validate_field/2)

      if Enum.empty?(error_map) do
        dataset
      else
        %Dataset{
          data: dataset.data,
          valid?: false,
          error: %MapErrors{
            errors: error_map
          }
        }
      end
    else
      type_result
    end
  end

  defp validate_field({fieldname, field_spec}, {data, error_map}) do
    value = Access.get(data, fieldname, nil)

    result =
      case field_spec do
        {:optional, validator} ->
          is_null_or_validate(value, validator)

        validator ->
          validator.(value)
      end

    if result.valid? do
      {data, error_map}
    else
      {data, Map.put(error_map, fieldname, result.error)}
    end
  end

  defp is_null_or_validate(value, validator) do
    if value == nil || value == "" do
      %Dataset{data: value, valid?: true, error: nil}
    else
      validator.(value)
    end
  end
end
