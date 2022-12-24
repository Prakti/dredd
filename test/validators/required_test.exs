defmodule Dredd.Validators.RequiredTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_required/2" do
    test "adds an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :required,
                 message: "can't be blank",
                 metadata: %{}
               }
             } = Dredd.validate_required(data)
    end

    test "adds an error if value is an empty string" do
      data = ""

      assert %Dredd.Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :required,
                 message: "can't be blank",
                 metadata: %{}
               }
             } = Dredd.validate_required(data)
    end

    property "adds an error if value is only whitespace and `:trim?` is `true`" do
      check all(whitespaces <- string([?\s, ?\t, ?\n, ?\v, ?\f, ?\r], min_length: 1)) do
        data = whitespaces

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: false,
                 error: %SingleError{
                   validator: :required,
                   message: "can't be blank",
                   metadata: %{}
                 }
               } = Dredd.validate_required(data, trim?: true)
      end
    end

    property "does not add an error if value is not nil or only whitespace" do
      check all(str_value <- string(:printable, min_length: 1)) do
        data = str_value

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
              } = Dredd.validate_required(data)
      end
    end

    property "does not add an error if value is only whitespace and `:trim?` is `false`" do
      check all(whitespaces <- string([?\s, ?\t, ?\n, ?\v, ?\f, ?\r], min_length: 1)) do
        data = whitespaces

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
              } = Dredd.validate_required(data, trim?: false)
      end
    end

    property "does not add an error if value is not a string" do
      check all(
              data <- term(),
              not (is_binary(data) and String.valid?(data))
            ) do

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
              } = Dredd.validate_required(data)
      end
    end

    test "passes through invalid datasets and does not execute validation" do
      value = %Dataset{
        data: nil,
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing passthrough",
          metadata: %{}
        }
      }

      assert ^value = Dredd.validate_required(value)
    end

    test "uses a custom error message when provided" do
      message = "message"

      data = nil

      assert %Dredd.Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :required,
                 message: ^message,
                 metadata: %{}
               }
             } = Dredd.validate_required(data, message: message)
    end
  end
end
