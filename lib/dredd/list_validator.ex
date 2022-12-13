defmodule Dredd.ListValidator do
  @moduledoc """
  Applies all given validators on the elements of an enumerable. Checks if the
  given value is enumerable.
  """

  alias Dredd.{
    ListErrors,
    ListResult,
    SingleResult,
  }

  # TODO: 2022-12-13 Write Test for ListValidator
  # TODO: 2022-12-13 Think about joining all Result Types
  @type single_validator_fun :: (any() -> SingleResult.t())

  @spec call(any(), single_validator_fun()) :: ListResult.t()
  def call(%ListResult{valid?: false} = result, _validator) do
    result
  end

  def call(%ListResult{} = result, validator) do
    validate(result, validator)
  end

  def call(value, validator) do
    validate(%ListResult{data: value}, validator)
  end

  def validate(in_result, validator) do
    enumerable_result = Dredd.Validators.Enumerable.call(in_result.data)

    if enumerable_result.valid? do
      indexed_enum =
        in_result.data
        |> Enum.with_index(fn element, index -> {index, element} end)

      list_errors = 
        indexed_enum 
        |> Enum.reduce(%{}, fn {idx, value}, list_errors -> 
          result = validator.(value)

          unless result.valid? do
            Map.put(list_errors, idx, result.error)
          else
            list_errors
          end
        end)

      %ListResult{
        data: in_result.data,
        valid?: Enum.empty?(list_errors),
        error: %ListErrors{
          errors: list_errors 
        }
      }
    else
      %ListResult{ 
        data: in_result.data,
        valid?: false,
        error: enumerable_result.error
      }
    end
  end

end
