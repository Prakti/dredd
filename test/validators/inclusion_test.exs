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

    test "does not add an error if value is nil" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_inclusion(data, ["a value"])
    end

    test "does not add an error if value is an empty string" do
      data = ""

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_inclusion(data, ["a value"])
    end
  end
end
