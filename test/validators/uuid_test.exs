defmodule Dredd.Validators.UUIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.Dataset

  def uuid_gen do
    uuid_bytes = {
      binary(length: 4),
      binary(length: 2),
      binary(length: 2),
      binary(length: 2),
      binary(length: 6)
    }

    bytes_to_string = fn bytes ->
      bytes
      |> Tuple.to_list()
      |> Enum.map_join("-", &Base.encode16/1)
      |> String.downcase()
    end

    StreamData.tuple(uuid_bytes)
    |> StreamData.map(bytes_to_string)
  end

  def invalid_uuid_gen do
    filter(term(), fn data -> not (is_binary(data) and data == "") end)
  end

  describe "validate_uuid" do
    property "correctly validates all uuid4 given in map" do
      check all(
              uuid <- uuid_gen(),
              foo <- term(),
              bar <- term()
            ) do
        data = %{uuid: uuid, foo: foo, bar: bar}

        result =
          data
          |> Dredd.validate_required(:uuid)
          |> Dredd.validate_uuid(:uuid)

        assert result.data == data
        assert result.valid? == true
        assert result.errors == []
      end
    end

    property "correctly validates all uuid4 given in a Dataset" do
      check all(
              uuid <- uuid_gen(),
              foo <- term(),
              bar <- term()
            ) do
        data = %{uuid: uuid, foo: foo, bar: bar}
        dataset = Dataset.new(data)

        result =
          dataset
          |> Dredd.validate_required(:uuid)
          |> Dredd.validate_uuid(:uuid)

        assert result.data == data
        assert result.valid? == true
        assert result.errors == []
      end
    end

    property "does not validate non-uuid4 data given in a map" do
      check all(
              wrong_uuid <- invalid_uuid_gen(),
              foo <- term(),
              bar <- term()
            ) do
        data = %{uuid: wrong_uuid, foo: foo, bar: bar}

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: false,
                 errors: [uuid: {"is not a valid uuid", [validation: :uuid]}]
               } = Dredd.validate_uuid(data, :uuid)
      end
    end

    property "does not validate non-uuid4 data given in a Dataset" do
      check all(
              wrong_uuid <- invalid_uuid_gen(),
              foo <- term(),
              bar <- term()
            ) do
        data = %{uuid: wrong_uuid, foo: foo, bar: bar}
        dataset = Dataset.new(data)

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: false,
                 errors: [uuid: {"is not a valid uuid", [validation: :uuid]}]
               } = Dredd.validate_uuid(dataset, :uuid)
      end
    end
  end
end
