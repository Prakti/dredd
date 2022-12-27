defmodule Dredd.Validators.BooleanTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_boolean/2" do
    property "correctly validates against boolean types" do
      check all(
              data <- term(),
              raw? <- boolean()
            ) do
        dataset = if raw?, do: data, else: %Dataset{data: data}

        if is_boolean(data) do
          assert %Dataset{
                   data: ^data,
                   error: nil,
                   valid?: true
                 } = Dredd.validate_boolean(dataset)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :boolean,
                     message: "is not a boolean",
                     metadata: %{kind: :type}
                   },
                   valid?: false
                 } = Dredd.validate_boolean(dataset)
        end
      end
    end

    property "correctly validates against expected values" do
      check all(
              data <- term(),
              raw? <- boolean(),
              expected <- boolean()
            ) do
        dataset = if raw?, do: data, else: %Dataset{data: data}

        if data == expected do
          assert %Dataset{
                   data: ^data,
                   error: nil,
                   valid?: true
                 } = Dredd.validate_boolean(dataset, is: expected)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :boolean,
                     message: "expected value: %{expected}",
                     metadata: %{expected: ^expected, kind: :value}
                   },
                   valid?: false
                 } = Dredd.validate_boolean(dataset, is: expected)
        end
      end
    end

    test "adds an error if `nil` is given" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :boolean,
                 message: "is not a boolean",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_boolean(data)
    end

    test "allows override of `:wrong_type_message`" do
      data = nil
      message = "message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :boolean,
                 message: ^message,
                 metadata: %{kind: :type}
               },
               valid?: false
             } = Dredd.validate_boolean(data, wrong_type_message: message)
    end

    test "allows override of `:wrong_value_message`" do
      data = nil
      expected = true
      message = "message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :boolean,
                 message: ^message,
                 metadata: %{expected: ^expected, kind: :value}
               },
               valid?: false
             } = Dredd.validate_boolean(data, is: expected, wrong_value_message: message)
    end

    test "passes through already invalid datasets and does not execute validation" do
      dataset = %Dataset{
        data: nil,
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "passthrough",
          metadata: %{foo: "bar"}
        }
      }

      assert dataset == Dredd.validate_boolean(dataset, is: true)
    end
  end
end
