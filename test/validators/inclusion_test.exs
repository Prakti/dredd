defmodule Dredd.Validators.InclusionTest do
  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_inclusion/4" do
    test "adds an error if value is not contained within enum" do
      data = "value"
      enum = ["another value"]

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :inclusion,
                 message: "is invalid",
                 metadata: %{enum: ^enum}
               },
               valid?: false
             } = Dredd.validate_inclusion(data, enum)
    end

    test "does not add an error if the value is not contained within enum" do
      value = "value"

      assert %Dataset{
               data: ^value,
               error: nil,
               valid?: true
             } = Dredd.validate_inclusion(value, [value])
    end

    test "uses a custom error message when provided" do
      message = "message"
      data = "value"
      enum = ["another value"]

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :inclusion,
                 message: ^message,
                 metadata: %{enum: ^enum}
               },
               valid?: false
             } = Dredd.validate_inclusion(data, enum, message: message)
    end

    test "adds an error if value is nil" do
      data = nil
      enum = ["a value"]

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :inclusion,
                 message: "is invalid",
                 metadata: %{enum: ^enum}
               },
               valid?: false
             } = Dredd.validate_inclusion(data, enum)
    end

    test "does not add an error if value is an empty string" do
      data = ""
      enum = ["a value"]

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :inclusion,
                 message: "is invalid",
                 metadata: %{enum: ^enum}
               },
               valid?: false
             } = Dredd.validate_inclusion(data, enum)
    end

    test "does an early abort if given dataset is already invalid" do
      enum = ["another value"]

      data = %Dataset{
        data: "foo",
        error: %SingleError{
          validator: :passthrough,
          message: "testing early abort",
          metadata: %{}
        },
        valid?: false
      }

      assert %Dataset{
               data: "foo",
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing early abort",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_inclusion(data, enum)
    end
  end
end
