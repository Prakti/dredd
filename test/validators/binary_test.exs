defmodule Dredd.Validators.BinaryTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  # TODO: 2022-12-27 - Test error-message overrides

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
               } = Dredd.validate_binary(value, is: correct_length)
      end
    end

    property "does not add an error if value's length is greater than `:min`" do
      check all(value <- binary(min_length: 2)) do
        min_length = byte_size(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(value, min: min_length)
      end
    end

    property "does not add an error if value's length is less than `:max`" do
      check all(value <- binary(min_length: 1)) do
        max_length = byte_size(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_binary(value, max: max_length)
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
            kind: :is
          }
        }

        assert %Dataset{
                 data: ^value,
                 error: ^expected_error,
                 valid?: false
               } = Dredd.validate_binary(value, is: wrong_length)
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
                     kind: :min
                   }
                 }
               } = Dredd.validate_binary(value, min: wrong_length)
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
                     kind: :max
                   }
                 }
               } = Dredd.validate_binary(value, max: wrong_length)
      end
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
