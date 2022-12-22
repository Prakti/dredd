defmodule Dredd.Validators.FormatTest do
  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_format/4" do
    test "adds an error if value does not match the provided format" do
      data = "foo"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :format,
                 message: "has invalid format",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_format(data, ~r/\d/)
    end

    test "does not add an error if value does match the provided format" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_format(data, ~r/#{data}/)
    end

    test "uses a custom error message when provided" do
      message = "message"
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :format,
                 message: ^message,
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_format(data, ~r/\d/, message: message)
    end

    test "do not add an error if value is nil" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_format(data, ~r/\d/)
    end

    test "do not add an error if value is a blank string" do
      data = ""

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_format(data, ~r/\d/)
    end

    test "does an early abort if given dataset is already invalid" do
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
             } = Dredd.validate_format(data, ~r/\d/)
    end
  end
end
