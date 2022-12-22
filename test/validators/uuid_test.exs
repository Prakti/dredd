defmodule Dredd.Validators.UUIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

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
    property "correctly validates single uuid4 value" do
      check all(uuid <- uuid_gen()) do
        assert %Dataset{
                 data: ^uuid,
                 valid?: true,
                 error: nil
               } = Dredd.validate_uuid(uuid)
      end
    end

    property "correctly validates single uuid4 value given in a dataset" do
      check all(uuid <- uuid_gen()) do
        assert %Dataset{
                 data: ^uuid,
                 valid?: true,
                 error: nil
               } = Dredd.validate_uuid(%Dataset{data: uuid})
      end
    end

    property "does not validate non-uuid4 value" do
      check all(wrong_uuid <- invalid_uuid_gen()) do
        assert %Dataset{
                 data: ^wrong_uuid,
                 valid?: false,
                 error: %SingleError{
                   validator: :uuid,
                   message: "is not a valid uuid",
                   metadata: %{}
                 }
               } = Dredd.validate_uuid(wrong_uuid)
      end
    end

    test "does an early abort if the given dataset is already invalid" do
      data = %Dataset{
        data: nil,
        valid?: false,
        error: %SingleError{
          validator: :passthrouh,
          message: "testing early abort",
          metadata: %{}
        }
      }

      assert %Dataset{
               data: nil,
               valid?: false,
               error: %SingleError{
                 validator: :passthrouh,
                 message: "testing early abort",
                 metadata: %{}
               }
             } = Dredd.validate_uuid(data)
    end
  end
end
