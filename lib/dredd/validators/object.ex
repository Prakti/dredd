defmodule Dredd.Validators.Object do
  @moduledoc false

  def call(dataset, field, validator) do
    dataset = Dredd.Dataset.new(dataset)

    value = Map.get(dataset.data, field)

    sub_result = validator.(value)

    unless sub_result.valid? do
      Dredd.put_error(dataset, field, sub_result.errors)
    else
      dataset
    end
  end
end
