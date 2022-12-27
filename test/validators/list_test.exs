defmodule Dredd.Validators.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    ListErrors,
    SingleError
  }

  # TODO: 2022-12-27 - Test error-message overrides

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

        result = Dredd.validate_list(value, &Dataset.new/1, is: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :is
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

        result = Dredd.validate_list(value, &Dataset.new/1, min: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have at least %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min
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

        result = Dredd.validate_list(value, &Dataset.new/1, max: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :list,
                   message: "should have at most %{count} item(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max
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
               } = Dredd.validate_list(value, &Dataset.new/1, is: count)
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
               } = Dredd.validate_list(value, &Dataset.new/1, min: count)
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
               } = Dredd.validate_list(value, &Dataset.new/1, max: count)
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
