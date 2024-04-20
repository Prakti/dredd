defmodule Dredd.Validators.StringTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_string/2" do
    property "does not add an error if given value is a string" do
      check all(data <- string(:printable)) do
        assert %Dataset{
                 data: ^data,
                 error: nil,
                 valid?: true
               } = Dredd.validate_string(data)
      end
    end

    test "adds an error if value is not a string" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :string,
                 message: "is not a string",
                 metadata: %{kind: :type}
               },
               valid?: false
             } = Dredd.validate_string(data)
    end

    property "correctly differentiates between strings and other data" do
      check all(data <- term()) do
        if is_binary(data) && String.valid?(data) do
          assert %Dataset{
                   data: ^data,
                   error: nil,
                   valid?: true
                 } = Dredd.validate_string(data)
        else
          assert %Dataset{
                   data: ^data,
                   error: %SingleError{
                     validator: :string,
                     message: "is not a string",
                     metadata: %{kind: :type}
                   },
                   valid?: false
                 } = Dredd.validate_string(data)
        end
      end
    end

    property "does not add an error if value's length matches `:exact_length`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints])
            ) do
        correct_length =
          case count do
            :graphemes ->
              length(String.graphemes(value))

            :codepoints ->
              length(String.codepoints(value))
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_string(value, exact_length: correct_length, count: count)
      end
    end

    property "does not add an error if value's length is greater than `:min`" do
      check all(
              value <- string(:printable, min_length: 2),
              count <- member_of([:graphemes, :codepoints])
            ) do
        min_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) - 1

            :codepoints ->
              length(String.codepoints(value)) - 1
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_string(value, min_length: min_length, count: count)
      end
    end

    property "does not add an error if value's length is less than `:max`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints])
            ) do
        max_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) + 1

            :codepoints ->
              length(String.codepoints(value)) + 1
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_string(value, max_lenth: max_length, count: count)
      end
    end

    property "adds an error if value's length does not exactly match `:is`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints]),
              wrong_length <- integer()
            ) do
        correct_length =
          case count do
            :graphemes ->
              length(String.graphemes(value))

            :codepoints ->
              length(String.codepoints(value))
          end

        wrong_length =
          if correct_length != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        expected_error = %SingleError{
          validator: :string,
          message: "should be %{count} character(s)",
          metadata: %{
            count: wrong_length,
            kind: :exact_length
          }
        }

        assert %Dataset{
                 data: ^value,
                 error: ^expected_error,
                 valid?: false
               } = Dredd.validate_string(value, count: count, exact_length: wrong_length)
      end
    end

    property "adds an error if value has a length less than `:min`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints]),
              excess_length <- integer()
            ) do
        correct_length =
          case count do
            :graphemes ->
              length(String.graphemes(value))

            :codepoints ->
              length(String.codepoints(value))
          end

        wrong_length = correct_length + 1 + abs(excess_length)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :string,
                   message: "should be at least %{count} character(s)",
                   metadata: %{
                     count: ^wrong_length,
                     kind: :min_length
                   }
                 }
               } = Dredd.validate_string(value, min_length: wrong_length, count: count)
      end
    end

    property "adds an error if value has a length greater than `:max`" do
      check all(
              value <- string(:printable, min_length: 5),
              count <- member_of([:graphemes, :codepoints])
            ) do
        correct_length =
          case count do
            :graphemes ->
              String.length(value)

            :codepoints ->
              length(String.codepoints(value))
          end

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
                   validator: :string,
                   message: "should be at most %{count} character(s)",
                   metadata: %{
                     count: ^wrong_length,
                     kind: :max_length
                   }
                 }
               } = Dredd.validate_string(value, max_length: wrong_length, count: count)
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

      assert dataset == Dredd.validate_string(dataset, max: 10)
    end

    test "allows setting `type_message`" do
      data = nil
      message = "type message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :string,
                 message: ^message,
                 metadata: %{kind: :type}
               },
               valid?: false
             } = Dredd.validate_string(data, type_message: message)
    end

    test "allows setting `exact_length_message`" do
      data = "foo"
      message = "exact length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :string,
                 message: ^message,
                 metadata: %{kind: :exact_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_string(data, exact_length: 10, exact_length_message: message)
    end

    test "allows setting `min_length_message`" do
      data = "foo"
      message = "min length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :string,
                 message: ^message,
                 metadata: %{kind: :min_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_string(data, min_length: 10, min_length_message: message)
    end

    test "allows setting `max_length_message`" do
      data = "This is way too long, Dude!"
      message = "max length message"

      assert %Dataset{
               data: ^data,
               error: %SingleError{
                 validator: :string,
                 message: ^message,
                 metadata: %{kind: :max_length, count: 10}
               },
               valid?: false
             } = Dredd.validate_string(data, max_length: 10, max_length_message: message)
    end
  end
end
