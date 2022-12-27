defmodule Validators.TypeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_number/3" do

    test "adds an error if value does not match type :float" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :float}
               },
               valid?: false
             } = Dredd.validate_number(data, :float)
    end

    test "adds an error if value does not match type :integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer)
    end

    test "adds an error if value does not match type :non_neg_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :non_neg_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :non_neg_integer)
    end

    test "adds an error if value is -1 for type :non_neg_integer" do
      data = -1

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :non_neg_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :non_neg_integer)
    end

    test "adds an error if value does not match type :pos_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :pos_integer)
    end

    test "adds an error if value is 0 for type :pos_integer" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :pos_integer)
    end

    test "adds an error if value is -1 for type :pos_integer" do
      data = -1

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: "is not a number",
                 metadata: %{kind: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :pos_integer)
    end



    test "raises an ArgumentError if type is not recognized" do
      data = "value"

      assert_raise ArgumentError, fn -> Dredd.validate_number(data, :nope) end
    end

    test "does not add an error if value matches type :float" do
      data = 1.0

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_number(data, :float)
    end

    test "does not add an error if value matches type :integer" do
      data = 1

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_number(data, :integer)
    end

    test "does not add an error if value matches type :non_neg_integer" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_number(data, :non_neg_integer)
    end

    test "does not add an error if value matches type :pos_integer" do
      data = 1

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_number(data, :pos_integer)
    end

    test "uses a custom error message when provided" do
      message = "message"

      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :number,
                 message: ^message,
                 metadata: %{kind: :integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer, message: message)
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
                 message: "is not a number",
                 metadata: %{kind: :integer}
               },
               valid?: false
             } = Dredd.validate_number(data, :integer)
    end
  end
end
