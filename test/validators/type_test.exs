defmodule Validators.TypeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_type/2" do
    test "adds an error if value does not match type :boolean" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :boolean}
               },
               valid?: false
             } = Dredd.validate_type(data, :boolean)
    end

    test "adds an error if value does not match type :float" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :float}
               },
               valid?: false
             } = Dredd.validate_type(data, :float)
    end

    test "adds an error if value does not match type :integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :integer)
    end

    test "adds an error if value does not match type :non_neg_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :non_neg_integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :non_neg_integer)
    end

    test "adds an error if value is -1 for type :non_neg_integer" do
      data = -1

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :non_neg_integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :non_neg_integer)
    end

    test "adds an error if value does not match type :pos_integer" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :pos_integer)
    end

    test "adds an error if value is 0 for type :pos_integer" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :pos_integer)
    end

    test "adds an error if value is -1 for type :pos_integer" do
      data = -1

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :pos_integer}
               },
               valid?: false
             } = Dredd.validate_type(data, :pos_integer)
    end

    test "adds an error if value does not match type :string" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :string}
               },
               valid?: false
             } = Dredd.validate_type(data, :string)
    end

    test "adds an error if value does not match type :list" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :list}
               },
               valid?: false
             } = Dredd.validate_type(data, :list)
    end

    test "adds an error if value does not match type :map" do
      data = "wrooong"

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :map}
               }
             } = Dredd.validate_type(data, :map)
    end

    test "raises an ArgumentError if type is not recognized" do
      data = "value"

      assert_raise ArgumentError, fn -> Dredd.validate_type(data, :nope) end
    end

    test "does not add an error if value matches type :boolean" do
      data = true

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :boolean)
    end

    test "does not add an error if value matches type :float" do
      data = 1.0

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :float)
    end

    test "does not add an error if value matches type :integer" do
      data = 1

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :integer)
    end

    test "does not add an error if value matches type :non_neg_integer" do
      data = 0

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :non_neg_integer)
    end

    test "does not add an error if value matches type :pos_integer" do
      data = 1

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :pos_integer)
    end

    test "does not add an error if value matches type :string" do
      data = "value"

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :string)
    end

    test "does not add an error if value matches type :list" do
      data = [1, 2, 3]

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :list)
    end

    test "does not add an error if value matches type :map" do
      data = %{foo: "bar", bang: 10}

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_type(data, :map)
    end

    test "uses a custom error message when provided" do
      message = "message"

      data = "value"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: ^message,
                 metadata: %{type: :boolean}
               },
               valid?: false
             } = Dredd.validate_type(data, :boolean, message: message)
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
             } = Dredd.validate_type(data, :boolean)
    end

    test "adds an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :type,
                 message: "has invalid type",
                 metadata: %{type: :boolean}
               },
               valid?: false
             } = Dredd.validate_type(data, :boolean)
    end
  end
end
