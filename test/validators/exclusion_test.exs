defmodule Dredd.Validators.ExclusionTest do
  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_exclusion/4" do
    test "adds an error if value is contained within enum" do
      value = "value"

      enum = [value]

      assert %Dataset{
               data: ^value,
               error: %SingleError{
                 validator: :exclusion,
                 message: "is reserved",
                 metadata: %{
                   enum: ^enum
                 }
               },
               valid?: false
             } = Dredd.validate_exclusion(value, enum)
    end

    test "does not add an error if the value is not contained within enum" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_exclusion(data, ["another value"])
    end

    test "uses a custom error message when provided" do
      value = "value"
      message = "message"
      enum = [value]

      assert %Dataset{
               data: ^value,
               error: %SingleError{
                 validator: :exclusion,
                 message: ^message,
                 metadata: %{
                   enum: ^enum
                 }
               },
               valid?: false
             } = Dredd.validate_exclusion(value, enum, message: message)
    end

    test "does not add an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_exclusion(data, ["a value"])
    end

    test "does an early abort if given dataset is already invalid" do
      enum = ["foo"]

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
             } = Dredd.validate_exclusion(data, enum)
    end
  end
end
