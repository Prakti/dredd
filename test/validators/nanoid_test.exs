defmodule Dredd.Validators.NanoIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.Dataset

  def nanoid_gen(len) do
    string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-], length: len)
  end

  describe "validate_nanoid" do
    property "correctly validates all nanoIDs given in a map" do
      check all(
              nanoid <- nanoid_gen(21),
              foo <- term(),
              bar <- term()
            ) do
        data = %{nanoid: nanoid, foo: foo, bar: bar}

        result =
          data
          |> Dredd.validate_required(:nanoid)
          |> Dredd.validate_nanoid(:nanoid)

        assert %Dataset{
                 data: ^data,
                 valid?: true,
                 errors: []
               } = result
      end
    end

    property "does not validate non-NanoID data given in a map" do
      check all(
              wrong_nanoid <- term(),
              foo <- term(),
              bar <- term()
            ) do
        wrong_nanoid =
          if is_binary(wrong_nanoid) do
            # invalidate all string just to be sure
            wrong_nanoid <> "💩"
          else
            wrong_nanoid
          end

        data = %{nanoid: wrong_nanoid, foo: foo, bar: bar}

        assert %Dataset{
                 data: ^data,
                 valid?: false,
                 errors: [nanoid: {"is not a valid NanoID", [validation: :nanoid]}]
               } = Dredd.validate_nanoid(data, :nanoid)
      end
    end
  end
end
