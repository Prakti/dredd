defmodule Dredd.Validators.AcceptanceTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  def everything_but_true do
    filter(term(), fn data -> data != true end)
  end

  describe "validate_acceptance/3" do
    test "adds an error if value is `false`" do
      data = false

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :acceptance,
                 message: "must be accepted",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_acceptance(data)
    end

    property "adds an error if value is everything but `true`" do
      check all(data <- everything_but_true()) do
        assert %Dataset{
                 data: ^data,
                 error: %SingleError{
                   validator: :acceptance,
                   message: "must be accepted",
                   metadata: %{}
                 },
                 valid?: false
               } = Dredd.validate_acceptance(data)
      end
    end

    test "does not add an error if value is `true`" do
      data = true

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_acceptance(data)
    end

    test "adds an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :acceptance,
                 message: "must be accepted",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_acceptance(data)
    end

    test "uses a custom error message when provided" do
      message = "message"
      data = false

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :acceptance,
                 message: ^message,
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_acceptance(data, message: message)
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
             } = Dredd.validate_acceptance(data)
    end
  end
end
