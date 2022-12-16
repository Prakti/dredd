defmodule Dredd.Validators.AcceptanceTest do
  use ExUnit.Case, async: true

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_acceptance/3" do
    test "adds an error if value is not `true`" do
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

    test "does not add an error if value is `true`" do
      data = true

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_acceptance(data)
    end

    test "does not add an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
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
  end
end
