defmodule Dredd.Validators.LengthTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_length/3 with strings as input" do
    # TODO: 2020-03-21 Consider positive cases below for string and all count pattern

    property "does not add an error if value's length matches `:is` exactly" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints, :bytes])
            ) do
        correct_length =
          case count do
            :graphemes ->
              length(String.graphemes(value))

            :codepoints ->
              length(String.codepoints(value))

            :bytes ->
              byte_size(value)
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, is: correct_length, count: count)
      end
    end

    property "does not add an error if value's length is greater than `:min`" do
      check all(
              value <- string(:printable, min_length: 2),
              count <- member_of([:graphemes, :codepoints, :bytes])
            ) do
        min_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) - 1

            :codepoints ->
              length(String.codepoints(value)) - 1

            :bytes ->
              byte_size(value) - 1
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, min: min_length, count: count)
      end
    end

    property "does not add an error if value's length is less than `:max`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints, :bytes])
            ) do
        max_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) + 1

            :codepoints ->
              length(String.codepoints(value)) + 1

            :bytes ->
              byte_size(value) + 1
          end

        assert %Dataset{
                 data: ^value,
                 error: nil,
                 valid?: true
               } = Dredd.validate_length(value, max: max_length, count: count)
      end
    end

    property "adds an error if value's length does not exactly match `:is`" do
      check all(
              value <- string(:printable, min_length: 1),
              wrong_length <- integer()
            ) do
        wrong_length =
          if String.length(value) != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        expected_error = %SingleError{
          validator: :length,
          message: "should be %{count} character(s)",
          metadata: %{
            count: wrong_length,
            kind: :is,
            type: :string
          }
        }

        assert %Dataset{
                 data: ^value,
                 error: ^expected_error,
                 valid?: false
               } = Dredd.validate_length(value, is: wrong_length)
      end
    end

    property "adds an error if value has a length less than `:min`" do
      check all(
              value <- string(:printable, min_length: 1),
              excess_length <- integer()
            ) do
        count = length(String.graphemes(value)) + 1 + abs(excess_length)

        result = Dredd.validate_length(value, min: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be at least %{count} character(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min,
                     type: :string
                   }
                 }
               } = result
      end
    end

    property "adds an error if value has a length greater than `:max`" do
      check all(value <- string(:printable, min_length: 5)) do
        count = String.length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(value, max: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be at most %{count} character(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max,
                     type: :string
                   }
                 }
               } = result
      end
    end

    property "adds an error if value's length does not exactly match `:is` when `:count` is `:codepoints`" do
      check all(
              value <- string(:printable, min_length: 1),
              wrong_length <- integer()
            ) do
        wrong_length =
          if length(String.codepoints(value)) != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        result = Dredd.validate_length(value, count: :codepoints, is: wrong_length)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be %{count} character(s)",
                   metadata: %{
                     count: ^wrong_length,
                     kind: :is,
                     type: :string
                   }
                 }
               } = result
      end
    end

    property "adds an error if value has a length less than `:min` when `:count` is `:codepoints`" do
      check all(
              value <- string(:printable, min_length: 1),
              excess_length <- integer()
            ) do
        count = length(String.codepoints(value)) + 1 + abs(excess_length)

        result = Dredd.validate_length(value, count: :codepoints, min: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be at least %{count} character(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min,
                     type: :string
                   }
                 }
               } = result
      end
    end

    property "adds an error if value has a length greater than `:max` when `:count` is `:codepoints`" do
      check all(value <- string(:printable, min_length: 5)) do
        count = length(String.codepoints(value))

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(value, count: :codepoints, max: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be at most %{count} character(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max,
                     type: :string
                   }
                 }
               } = result
      end
    end

    property "adds an error if value's length does not exactly match `:is` when `:count` is `:bytes`" do
      check all(
              value <- string(:printable, min_length: 5),
              wrong_length <- integer()
            ) do
        count = byte_size(value)

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
                   message: "should be %{count} byte(s)",
                   metadata: %{
                     count: ^count,
                     kind: :is,
                     type: :binary
                   }
                 }
               } = result
      end
    end

    property "adds an error if value has a length less than `:min` when `:count` is `:bytes`" do
      check all(
              value <- string(:printable, min_length: 1),
              excess_length <- integer()
            ) do
        count = byte_size(value) + 1 + abs(excess_length)

        result = Dredd.validate_length(value, count: :bytes, min: count)

        assert %Dataset{
                 data: ^value,
                 valid?: false,
                 error: %SingleError{
                   validator: :length,
                   message: "should be at least %{count} byte(s)",
                   metadata: %{
                     count: ^count,
                     kind: :min,
                     type: :binary
                   }
                 }
               } = result
      end
    end

    property "adds an error if value has a length greater than `:max` when `:count` is `:bytes`" do
      check all(value <- string(:printable, min_length: 5)) do
        count = byte_size(value)

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
                   message: "should be at most %{count} byte(s)",
                   metadata: %{
                     count: ^count,
                     kind: :max,
                     type: :binary
                   }
                 }
               } = result
      end
    end
  end

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
    test "does not add an error if value is nil" do
      data = nil

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_length(data, is: 1)
    end

    test "does not add an error if value is an empty string" do
      data = ""

      assert %Dataset{
               data: ^data,
               error: nil,
               valid?: true
             } = Dredd.validate_length(data, is: 1)
    end

    property "can correctly handle arbitrary data" do
      check all(value <- term()) do
        if (is_binary(value) and value != "") or is_list(value) do
          assert %Dataset{
                   data: ^value,
                   valid?: false,
                   error: _error
                 } = Dredd.validate_length(value, is: -1)
        else
          assert %Dataset{
                   data: ^value,
                   error: nil,
                   valid?: true
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
  end
end
