defmodule Dredd.Validators.LengthTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_length/3 with lists as input" do
    property "adds an error if value is a list and does not exactly match `:is`" do
      check all(
              value <- list_of(term(), min_length: 2),
              wrong_length <- positive_integer()
            ) do
        count = length(value)

        count =
          if count == wrong_length do
            count - 1
          else
            wrong_length
          end

        result = Dredd.validate_length(value, count: :bytes, is: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should have %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :is,
                     type: :list
                   }
                 }
               } = result
      end
    end

    property "adds an error if value is a list with fewer items than `:min`" do
      check all(
              value <- list_of(term(), min_length: 1),
              excess_length <- positive_integer()
            ) do
        count = length(value) + 1 + excess_length

        result = Dredd.validate_length(value, count: :bytes, min: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should have at least %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min,
                     type: :list
                   }
                 }
               } = result
      end
    end

    property "adds an error if value is a list with more items than `:max`" do
      check all(value <- list_of(term(), min_length: 5)) do
        count = length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(value, count: :bytes, max: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should have at most %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max,
                     type: :list
                   }
                 }
               } = result
      end
    end

    property "does not add an error if value's length matches `:is` exactly" do
      check all(value <- list_of(term(), min_length: 2)) do
        count = length(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, is: count)
      end
    end

    property "does not add an error if value has a length greater than `:min`" do
      check all(value <- list_of(term(), min_length: 2)) do
        count = length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, min: count)
      end
    end

    property "does not add an error if value has a length less than `:max`" do
      check all(
              value <- list_of(term(), min_length: 2),
              excess_length <- positive_integer()
            ) do
        count = length(value) + excess_length

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, max: count)
      end
    end
  end

  describe "validate_length/3 with nonsupported types as input" do
    test "adds an error if value is `nil`" do
      data = nil

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :length,
                 message: "has incompatible type.",
                 metadata: %{}
               }
             } = Dredd.validate_length(data, is: 1)
    end

    test "adds an error if value is an empty string" do
      data = ""

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :length,
                 message: "should be %{count} character(s)",
                 metadata: %{}
               }
             } = Dredd.validate_length(data, is: 1)
    end

    property "adds an error for arbitrary wrong data" do
      check all(value <- term()) do
        if is_binary(value) or is_list(value) do
          assert %Dataset{
                   data: ^value,
                   valid?: false,
                   error: _error
                 } = Dredd.validate_length(value, is: -1)
        end
      end
    end
  end

  describe "validate_length/3" do
    test "uses a custom error message when provided" do
      value = "é"
      message = "message"
      count = length(String.graphemes(value)) + 1

      assert %Dataset{
               data: ^value,
               valid?: false,
               error: %SingleError{
                 validator: :length,
                 message: ^message,
                 metadata: %{
                   count: ^count,
                   kind: :is,
                   type: :string
                 }
               }
             } = Dredd.validate_length(value, is: count, message: message)
    end

    test "adds an error if given value is neither binary nor list" do
    end

    test "does an early abort if given dataset is already invalid" do
      data = %Dataset{
        data: "foo",
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing early abort",
          metadata: %{}
        }
      }

      assert %Dataset{
               data: "foo",
               valid?: false,
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing early abort",
                 metadata: %{}
               }
             } = Dredd.validate_length(data, is: 10)
    end
  end
end
