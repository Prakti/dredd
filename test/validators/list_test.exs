defmodule Dredd.Validators.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    ListErrors,
    SingleError
  }

  describe "validate_list" do
    test "adds errors for invalid values in a given list" do
      data = ["string", -1, "string", 0]

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %ListErrors{
                 validator: :list,
                 errors: %{
                   1 => %SingleError{
                     validator: :string,
                     message: "is not a string",
                     metadata: %{kind: :type}
                   },
                   3 => %SingleError{
                     validator: :string,
                     message: "is not a string",
                     metadata: %{kind: :type}
                   }
                 }
               }
             } = Dredd.validate_list(data, validator)
    end

    property "correctly handles arbitrary lists" do
      validator = fn data ->
        Dredd.validate_string(data)
      end

      check all(data <- list_of(term())) do
        expected_errors =
          data
          |> Enum.with_index()
          |> Enum.reduce(%{}, fn {item, index}, errors ->
            if String.valid?(item) do
              errors
            else
              Map.put(errors, index, %SingleError{
                validator: :string,
                message: "is not a string",
                metadata: %{kind: :type}
              })
            end
          end)

        if Enum.empty?(expected_errors) do
          assert %Dataset{
                   data: ^data,
                   valid?: true,
                   error: nil
                 } = Dredd.validate_list(data, validator)
        else
          assert %Dataset{
                   data: ^data,
                   valid?: false,
                   error: %ListErrors{
                     validator: :list,
                     errors: ^expected_errors
                   }
                 } = Dredd.validate_list(data, validator)
        end
      end
    end

    property "correctly handles arbitrary lists with valid data" do
      validator = fn data ->
        Dredd.validate_string(data)
      end

      check all(data <- list_of(string(:printable, min_length: 1))) do
        assert %Dataset{
                 data: ^data,
                 valid?: true,
                 error: nil
               } = Dredd.validate_list(data, validator)
      end
    end

    property "adds an error if value is a list and does not exactly match `:exact_length`" do
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

        result = Dredd.validate_list(value, &Dataset.new/1, exact_length: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :exact_length
                   }
                 }
               } = result
      end
    end

    property "adds an error if value is a list with fewer items than `:min_length`" do
      check all(
              value <- list_of(term(), min_length: 1),
              excess_length <- positive_integer()
            ) do
        count = length(value) + 1 + excess_length

        result = Dredd.validate_list(value, &Dataset.new/1, min_length: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have at least %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min_length
                   }
                 }
               } = result
      end
    end

    property "adds an error if value is a list with more items than `:max_length`" do
      check all(value <- list_of(term(), min_length: 5)) do
        count = length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_list(value, &Dataset.new/1, max_length: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have at most %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max_length
                   }
                 }
               } = result
      end
    end

    property "does not add an error if value's length matches `:exact_length` exactly" do
      check all(value <- list_of(term(), min_length: 2)) do
        count = length(value)

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_list(value, &Dataset.new/1, exact_length: count)
      end
    end

    property "does not add an error if value has a length greater than `:min_length`" do
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
               } = Dredd.validate_list(value, &Dataset.new/1, min_length: count)
      end
    end

    property "does not add an error if value has a length less than `:max_length`" do
      check all(
              value <- list_of(term(), min_length: 2),
              excess_length <- positive_integer()
            ) do
        count = length(value) + excess_length

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_list(value, &Dataset.new/1, max_length: count)
      end
    end

    test "sets a SingleError if given value is not a list" do
      data = 100

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: "is not a list",
                 metadata: %{kind: :type}
               }
             } = Dredd.validate_list(data, validator)
    end

    test "sets a SingleError if given value is `nil`" do
      data = nil

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: "is not a list",
                 metadata: %{kind: :type}
               }
             } = Dredd.validate_list(data, validator)
    end

    test "allows setting `type_message`" do
      data = 100
      message = "type message"

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: ^message,
                 metadata: %{kind: :type}
               }
             } = Dredd.validate_list(data, validator, type_message: message)
    end

    test "allows setting `exact_length_message`" do
      data = ["foo", "foo", "foo"]
      message = "exact length message"

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: ^message,
                 metadata: %{kind: :exact_length, count: 10}
               }
             } =
               Dredd.validate_list(data, validator,
                 exact_length: 10,
                 exact_length_message: message
               )
    end

    test "allows setting `min_length_message`" do
      data = ["foo", "foo", "foo"]
      message = "min length message"

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: ^message,
                 metadata: %{kind: :min_length, count: 10}
               }
             } = Dredd.validate_list(data, validator, min_length: 10, min_length_message: message)
    end

    test "allows setting `max_length_message`" do
      data = ["This", "is", "way", "too", "large", "Dude!"]
      message = "max length message"

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :list,
                 message: ^message,
                 metadata: %{kind: :max_length, count: 2}
               }
             } = Dredd.validate_list(data, validator, max_length: 2, max_length_message: message)
    end

    test "does an early abort if a given dataset is already invalid" do
      data = %Dataset{
        data: [],
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing the early abort",
          metadata: %{}
        }
      }

      validator = fn data ->
        Dredd.validate_string(data)
      end

      assert %Dataset{
               data: [],
               valid?: false,
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing the early abort",
                 metadata: %{}
               }
             } = Dredd.validate_list(data, validator)
    end
  end
end
