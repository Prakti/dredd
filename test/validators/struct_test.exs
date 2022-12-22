defmodule Dredd.Validators.StructTest do
  @moduledoc false

  use ExUnit.Case, async: true
  
  alias Dredd.{
   Dataset,
   SingleError,
   StructErrors,
  }

  describe "validate_struct " do
    test "returns an error if the value is not 'Access'able" do
      value = "foo"
      structure = %{
        field_a: fn (data) -> Dredd.validate_type(data, :string) end,
        field_b: fn (data) -> Dredd.validate_type(data, :integer) end,
      }

      assert %Dataset{
        data: ^value,
        valid?: false,
        error: %SingleError{
          validator: :type,
          message: "has invalid type",
          metadata: %{type: :struct}
        }
      } = Dredd.validate_struct(value, structure)
    end

    test "returns a StructError if validation of a field failed" do
      value = %{ 
        field_a: 10,
        field_b: "foo"
      }
      structure = %{
        field_a: fn (data) -> Dredd.validate_type(data, :string) end,
        field_b: fn (data) -> Dredd.validate_type(data, :integer) end,
      }

      assert %Dataset{
        data: ^value,
        valid?: false,
        error: %StructErrors{
          validator: :struct,
          errors: %{
            field_a: %SingleError{
              validator: :type,
              message: "has invalid type",
              metadata: %{type: :string}
            },
            field_b: %SingleError{
              validator: :type,
              message: "has invalid type",
              metadata: %{type: :integer}
            }
          }
        }
      } = Dredd.validate_struct(value, structure)
    end

    test "correctly handles valid structs" do
      value = %{
        field_a: "string",
        field_b: 100
      }
      structure = %{
        field_a: fn (data) -> Dredd.validate_type(data, :string) end,
        field_b: fn (data) -> Dredd.validate_type(data, :integer) end,
      }

      assert %Dataset{
        data: ^value,
        valid?: true,
        error: nil
      } = Dredd.validate_struct(value, structure)
    end

  end
end
