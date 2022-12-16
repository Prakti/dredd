defmodule Dredd.Validators.Enumerable do
  @moduledoc false

  @default_message "is not enumerable"

  def call(dataset, _opts) do
    dataset = Dredd.Dataset.new(dataset)

    data = dataset.data

    if Enumerable.impl_for(data) != nil do
      dataset
    else
      Dredd.set_single_error(dataset, @default_message, :enumerable)
    end
  end
end
