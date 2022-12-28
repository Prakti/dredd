defmodule DreddTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest Dredd

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "set_single_error\4" do
    property "does correctly handle given data" do
      check all(
              data <- term(),
              message <- string(:printable),
              validator <- atom(:alphanumeric),
              metadata <- map_of(atom(:alphanumeric), term())
            ) do
        dataset = Dataset.new(data)

        assert %Dataset{
                 data: ^data,
                 valid?: false,
                 error: %SingleError{
                   validator: ^validator,
                   message: ^message,
                   metadata: ^metadata
                 }
               } = Dredd.set_single_error(dataset, message, validator, metadata)
      end
    end
  end
end
