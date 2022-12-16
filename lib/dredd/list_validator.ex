defmodule Dredd.ListValidator do
  @moduledoc """
  Applies all given validators on the elements of an enumerable. Checks if the
  given value is enumerable.
  """

  alias Dredd.{
    Dataset,
    ListErrors
  }

  # TODO: 2022-12-13 Write Test for ListValidator
  @type single_validator_fun :: (any() -> Dataset.t())

  @spec call(any(), single_validator_fun()) :: Dataset.t()
  def call(%Dataset{valid?: false} = result, _validator) do
    result
  end

  def call(%Dataset{} = result, validator) do
    validate(result, validator)
  end

  def call(value, validator) do
    validate(%Dataset{data: value}, validator)
  end

  def validate(in_result, validator) do
    enumerable_result = Dredd.validate_enumerable(in_result.data)

    if enumerable_result.valid? do
      list_errors =
        in_result.data
        |> Enum.with_index(fn element, index -> {index, element} end)
        |> Enum.reduce(%{}, fn {idx, value}, list_errors ->
          result = validator.(value)

          unless result.valid? do
            Map.put(list_errors, idx, result.error)
          else
            list_errors
          end
        end)

      %Dataset{
        data: in_result.data,
        valid?: Enum.empty?(list_errors),
        error: %ListErrors{
          errors: list_errors
        }
      }
    else
      %Dataset{
        data: in_result.data,
        valid?: false,
        error: enumerable_result.error
      }
    end
  end
end
