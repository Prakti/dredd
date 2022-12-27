defmodule Dredd.Validators.BinaryTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_binary/2" do
    test "adds an error if value is not a binary" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :binary,
                 message: "is not a binary",
                 metadata: %{kind: :type}
               },
               valid?: false
             } = Dredd.validate_binary(data)
    end

    property "does not add an error if given value is a binary" do
      check all(data <- binary()) do
        assert %Dataset{
                 data: ^data,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(data)
      end
    end

    property "correctly differentiates between binary and other data" do
      check all(data <- term()) do
        if is_binary(data) do
          assert %Dataset{
                   data: ^data,
                   error: nil,
                   valid?: true
                 } = Dredd.validate_binary(data)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :binary,
                     message: "is not a binary",
                     metadata: %{kind: :type}
                   },
                   valid?: false
                 } = Dredd.validate_binary(data)
        end
      end
    end

    property "does not add an error if value's length matches `:is` exactly" do
      check all(value <- binary(min_length: 1)) do
        correct_length = byte_size(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(value, exact_length: correct_length)
      end
    end

    property "does not add an error if value's length is greater than `:min`" do
      check all(value <- binary(min_length: 2)) do
        min_length = byte_size(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(value, min_length: min_length)
      end
    end

    property "does not add an error if value's length is less than `:max`" do
      check all(value <- binary(min_length: 1)) do
        max_length = byte_size(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(value, max_length: max_length)
      end
    end

    property "adds an error if value's length does not exactly match `:is`" do
      check all(
              value <- string(:printable, min_length: 1),
              wrong_length <- integer()
            ) do
        wrong_length =
          if byte_size(value) != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        expected_error = %SingleError{
          validator: :binary,
          message: "should be %{count} byte(s)",
          metadata: %{
            count: wrong_length,
            kind: :exact_length
          }
        }

        assert %Dataset{
                 data: ^value,
                 error: ^expected_error,
                 valid?: false
               } = Dredd.validate_binary(value, exact_length: wrong_length)
      end
    end

    property "adds an error if value has a length less than `:min`" do
      check all(
              value <- binary(min_length: 1),
              excess_length <- positive_integer()
            ) do
        wrong_length = byte_size(value) + 1 + excess_length

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :binary,
                   message: "should be at least %{count} byte(s)",
                   metadata: %{
                     count: ^wrong_length,
                     kind: :min_length
                   }
                 }
               } = Dredd.validate_binary(value, min_length: wrong_length)
      end
    end

    property "adds an error if value has a length greater than `:max`" do
      check all(value <- string(:printable, min_length: 5)) do
        correct_length = byte_size(value)

        wrong_length =
          if correct_length < 10 do
            correct_length - 1
          else
            List.first(Enum.take(integer(1..(correct_length - 2)), 1))
          end

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :binary,
                   message: "should be at most %{count} byte(s)",
                   metadata: %{
                     count: ^wrong_length,
                     kind: :max_length
                   }
                 }
               } = Dredd.validate_binary(value, max_length: wrong_length)
      end
    end

    test "allows override of `type_message`" do
      data = nil
      message = "type message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :binary,
                 message: ^message,
                 metadata: %{kind: :type}
               },
               valid?: false
             } = Dredd.validate_binary(data, type_message: message)
    end

    test "allows override of `exact_length_message`" do
      data = "foo"
      message = "exact length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :binary,
                 message: ^message,
                 metadata: %{kind: :exact_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_binary(data, exact_length: 10, exact_length_message: message)
    end

    test "allows override of `min_length_message`" do
      data = "foo"
      message = "min length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :binary,
                 message: ^message,
                 metadata: %{kind: :min_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_binary(data, min_length: 10, min_length_message: message)
    end

    test "allows override of `max_length_message`" do
      data = "this is way too long, Dude!"
      message = "max length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :binary,
                 message: ^message,
                 metadata: %{kind: :max_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_binary(data, max_length: 10, max_length_message: message)
    end

    test "passes through invalid datasets and does not execute validation" do
      dataset = %Dataset{
        data: nil,
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "passthrough",
          metadata: %{meta: "data"}
        }
      }

      assert dataset == Dredd.validate_binary(dataset, max: 10)
    end
  end
end
