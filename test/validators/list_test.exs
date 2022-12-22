defmodule Dredd.Validators.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    ListErrors,
    SingleError
  }

  describe "validate_list" do
    test "adds errors for invalid values in a given list" do
      data = ["string", -1, "string", 0]

      validator = fn data ->
        Dredd.validate_type(data, :string)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %ListErrors{
                 validator: :list,
                 errors: %{
                   1 => %SingleError{
                     validator: :type,
                     message: "has invalid type",
                     metadata: %{type: :string}
                   },
                   3 => %SingleError{
                     validator: :type,
                     message: "has invalid type",
                     metadata: %{type: :string}
                   }
                 }
               }
             } = Dredd.validate_list(data, validator)
    end

    test "does not return errors if all items in a list validate" do
      data = ["string", "string", "string", "string"]

      validator = fn data ->
        Dredd.validate_type(data, :string)
      end

      assert %Dredd.Dataset{
               data: ^data,
               valid?: true,
               error: nil
             } = Dredd.validate_list(data, validator)
    end

    test "sets a SingleError if given value is not enumerable" do
      data = 100

      validator = fn data ->
        Dredd.validate_type(data, :string)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{ type: :enumerable }
               }
             } = Dredd.validate_list(data, validator)
    end

    test "does an early abort if a given dataset is already invalid" do
      data = %Dataset{
        data: [],
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing the early abort",
          metadata: %{}
        }
      }

      validator = fn data ->
        Dredd.validate_type(data, :string)
      end

      assert %Dataset{
               data: [],
               valid?: false,
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing the early abort",
                 metadata: %{}
               }
             } = Dredd.validate_list(data, validator)
    end
  end
end
