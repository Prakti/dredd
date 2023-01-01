defmodule Dredd.Validators.MapTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    MapErrors,
    SingleError
  }

  defmodule TestStruct do
    defstruct field_a: nil, field_b: nil
  end

  describe "validate_map/2" do
    test "returns an error if the value is not a map" do
      value = "foo"

      structure = %{
        field_a: fn data -> Dredd.validate_string(data) end,
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert %Dataset{
               data: ^value,
               valid?: false,
               error: %SingleError{
                 validator: :map,
                 message: "is not a map",
                 metadata: %{kind: :type}
               }
             } = Dredd.validate_map(value, structure)
    end

    test "returns a StructError if validation of a field failed" do
      value = %{
        field_a: 10,
        field_b: "foo"
      }

      structure = %{
        field_a: fn data -> Dredd.validate_string(data) end,
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert %Dataset{
               data: ^value,
               valid?: false,
               error: %MapErrors{
                 validator: :map,
                 errors: %{
                   field_a: %SingleError{
                     validator: :string,
                     message: "is not a string",
                     metadata: %{kind: :type}
                   },
                   field_b: %SingleError{
                     validator: :number,
                     message: "has incorrect numerical type",
                     metadata: %{kind: :integer}
                   }
                 }
               }
             } = Dredd.validate_map(value, structure)
    end

    test "correctly handles valid maps" do
      value = %{
        field_a: "string",
        field_b: 100
      }

      structure = %{
        field_a: fn data -> Dredd.validate_string(data) end,
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert %Dataset{
               data: ^value,
               valid?: true,
               error: nil
             } = Dredd.validate_map(value, structure)
    end

    test "correctly handles valid structs" do
      value = %TestStruct{
        field_a: "string",
        field_b: 100
      }

      structure = %{
        field_a: fn data -> Dredd.validate_string(data) end,
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert %Dataset{
               data: ^value,
               valid?: true,
               error: nil
             } = Dredd.validate_map(value, structure)
    end

    test "correctly handles valid structs with optional fields" do
      value = %{
        field_a: nil,
        field_b: 100
      }

      structure = %{
        field_a: {:optional, fn data -> Dredd.validate_string(data) end},
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert %Dataset{
               data: ^value,
               valid?: true,
               error: nil
             } = Dredd.validate_map(value, structure)
    end

    test "passes through invalid dataset and does not execute validation" do
      value = %Dataset{
        data: "not a map!",
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing passthrough",
          metadata: %{}
        }
      }

      structure = %{
        field_a: fn data -> Dredd.validate_string(data) end,
        field_b: fn data -> Dredd.validate_number(data, :integer) end
      }

      assert ^value = Dredd.validate_map(value, structure)
    end
  end
end
