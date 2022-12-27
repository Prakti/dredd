defmodule Validators.TypeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_number/3" do
    property "adds an error iff value is not a float" do
      check all(data <- term()) do
        if is_float(data) do
          assert %Dataset{
                   data: ^data,
                   valid?: true,
                   error: nil
                 } = Dredd.validate_number(data, :float)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :number,
                     message: "has incorrect numerical type",
                     metadata: %{kind: :float}
                   },
                   valid?: false
                 } = Dredd.validate_number(data, :float)
        end
      end
    end

    property "validates all float values" do
      check all(data <- float()) do
        assert %Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
               } = Dredd.validate_number(data, :float)
      end
    end

    property "adds an error iff value is not an integer" do
      check all(data <- term()) do
        if is_integer(data) do
          assert %Dataset{
                   data: ^data,
                   valid?: true,
                   error: nil
                 } = Dredd.validate_number(data, :integer)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :number,
                     message: "has incorrect numerical type",
                     metadata: %{kind: :integer}
                   },
                   valid?: false
                 } = Dredd.validate_number(data, :integer)
        end
      end
    end

    property "validates all integer values" do
      check all(data <- integer()) do
        assert %Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
               } = Dredd.validate_number(data, :integer)
      end
    end

    test "adds an error if value does not match type :non_neg_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "has incorrect numerical type",
                 metadata: %{kind: :non_neg_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :non_neg_integer)
    end

    property "adds an error iff a negative integer is given for non_neg_integer" do
      check all(data <- integer()) do
        if data < 0 do
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :number,
                     message: "has incorrect numerical type",
                     metadata: %{kind: :non_neg_integer}
                   },
                   valid?: false
                 } = Dredd.validate_number(data, :non_neg_integer)
        else
          assert %Dataset{
                   data: ^data,
                   valid?: true,
                   error: nil
                 } = Dredd.validate_number(data, :non_neg_integer)
        end
      end
    end

    test "adds an error if value does not match type :pos_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "has incorrect numerical type",
                 metadata: %{kind: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :pos_integer)
    end

    property "adds an error iff values <= 0 are given for pos_integer" do
      check all(data <- integer()) do
        if data <= 0 do
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :number,
                     message: "has incorrect numerical type",
                     metadata: %{kind: :pos_integer}
                   },
                   valid?: false
                 } = Dredd.validate_number(data, :pos_integer)
        else
          assert %Dataset{
                   data: ^data,
                   valid?: true,
                   error: nil
                 } = Dredd.validate_number(data, :pos_integer)
        end
      end
    end

    test "raises an ArgumentError if type is not recognized" do
      data = "value"

      assert_raise ArgumentError, fn -> Dredd.validate_number(data, :nope) end
    end

    property "does not add an error if value matches type :non_neg_integer" do
      check all(data <- integer()) do
        data = abs(data)

        assert %Dataset{
                 data: ^data,
                 error: nil,
                 valid?: true
               } = Dredd.validate_number(data, :non_neg_integer)
      end
    end

    test "does not add an error if value matches type :pos_integer" do
      check all(data <- positive_integer()) do
        assert %Dataset{
                 data: ^data,
                 error: nil,
                 valid?: true
               } = Dredd.validate_number(data, :pos_integer)
      end
    end

    test "uses a custom 'type_message` when provided" do
      message = "type message"

      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: ^message,
                 metadata: %{kind: :integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer, type_message: message)
    end

    test "uses a custom 'predicate_message` when provided" do
      message = "predicate message"
      data = 50
      predicate = fn _ -> false end

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: ^message,
                 metadata: %{kind: :predicate}
               },
               valid?: false
             } =
               Dredd.validate_number(data, :integer,
                 predicate_message: message,
                 predicate: predicate
               )
    end

    test "passes through invalid datasets and does not execute validation" do
      data = %Dataset{
        data: nil,
        error: %SingleError{
          validator: :passthrough,
          message: "testing early abort",
          metadata: %{}
        },
        valid?: false
      }

      assert %Dataset{
               data: nil,
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing early abort",
                 metadata: %{}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer)
    end

    test "adds an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "has incorrect numerical type",
                 metadata: %{kind: :integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer)
    end
  end
end
