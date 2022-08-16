defmodule Dredd.Validators.LengthTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  describe "validate_length/3 with strings as input" do
    # TODO: 2020-03-21 Consider positive cases below for string and all count pattern

    property "does not add an error if value's length matches `:is` exactly" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints, :bytes]),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        correct_length =
          case count do
            :graphemes ->
              length(String.graphemes(value))

            :codepoints ->
              length(String.codepoints(value))

            :bytes ->
              byte_size(value)
          end

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, is: correct_length, count: count)
      end
    end

    property "does not add an error if value's length is greater than `:min`" do
      check all(
              value <- string(:printable, min_length: 2),
              count <- member_of([:graphemes, :codepoints, :bytes]),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        min_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) - 1

            :codepoints ->
              length(String.codepoints(value)) - 1

            :bytes ->
              byte_size(value) - 1
          end

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, min: min_length, count: count)
      end
    end

    property "does not add an error if value's length is less than `:max`" do
      check all(
              value <- string(:printable, min_length: 1),
              count <- member_of([:graphemes, :codepoints, :bytes]),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        max_length =
          case count do
            :graphemes ->
              length(String.graphemes(value)) + 1

            :codepoints ->
              length(String.codepoints(value)) + 1

            :bytes ->
              byte_size(value) + 1
          end

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, max: max_length, count: count)
      end
    end

    property "adds an error if value's length does not exactly match `:is`" do
      check all(
              value <- string(:printable, min_length: 1),
              wrong_length <- integer(),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        wrong_length =
          if String.length(value) != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        expected_errors = [
          {field,
           {"should be %{count} character(s)",
            count: wrong_length, kind: :is, type: :string, validation: :length}}
        ]

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: ^expected_errors,
                 valid?: false
               } = Dredd.validate_length(data, field, is: wrong_length)
      end
    end

    property "adds an error if value has a length less than `:min`" do
      check all(
              value <- string(:printable, min_length: 1),
              field <- atom(:alphanumeric),
              excess_length <- integer()
            ) do
        data = Map.new([{field, value}])
        count = length(String.graphemes(value)) + 1 + abs(excess_length)

        result = Dredd.validate_length(data, field, min: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at least %{count} character(s)",
                   count: count, kind: :min, type: :string, validation: :length}}
               ]
      end
    end

    property "adds an error if value has a length greater than `:max`" do
      check all(
              value <- string(:printable, min_length: 5),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = String.length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(data, field, max: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at most %{count} character(s)",
                   count: count, kind: :max, type: :string, validation: :length}}
               ]
      end
    end

    property "adds an error if value's length does not exactly match `:is` when `:count` is `:codepoints`" do
      check all(
              value <- string(:printable, min_length: 1),
              wrong_length <- integer(),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        wrong_length =
          if length(String.codepoints(value)) != wrong_length do
            wrong_length
          else
            wrong_length + 1
          end

        result = Dredd.validate_length(data, field, count: :codepoints, is: wrong_length)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be %{count} character(s)",
                   count: wrong_length, kind: :is, type: :string, validation: :length}}
               ]
      end
    end

    property "adds an error if value has a length less than `:min` when `:count` is `:codepoints`" do
      check all(
              value <- string(:printable, min_length: 1),
              field <- atom(:alphanumeric),
              excess_length <- integer()
            ) do
        data = Map.new([{field, value}])
        count = length(String.codepoints(value)) + 1 + abs(excess_length)

        result = Dredd.validate_length(data, field, count: :codepoints, min: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at least %{count} character(s)",
                   count: count, kind: :min, type: :string, validation: :length}}
               ]
      end
    end

    property "adds an error if value has a length greater than `:max` when `:count` is `:codepoints`" do
      check all(
              value <- string(:printable, min_length: 5),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = length(String.codepoints(value))

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(data, field, count: :codepoints, max: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at most %{count} character(s)",
                   count: count, kind: :max, type: :string, validation: :length}}
               ]
      end
    end

    property "adds an error if value's length does not exactly match `:is` when `:count` is `:bytes`" do
      check all(
              value <- string(:printable, min_length: 5),
              wrong_length <- integer(),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = byte_size(value)

        count =
          if count == wrong_length do
            count - 1
          else
            wrong_length
          end

        result = Dredd.validate_length(data, field, count: :bytes, is: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be %{count} byte(s)",
                   count: count, kind: :is, type: :binary, validation: :length}}
               ]
      end
    end

    property "adds an error if value has a length less than `:min` when `:count` is `:bytes`" do
      check all(
              value <- string(:printable, min_length: 1),
              field <- atom(:alphanumeric),
              excess_length <- integer()
            ) do
        data = Map.new([{field, value}])
        count = byte_size(value) + 1 + abs(excess_length)

        result = Dredd.validate_length(data, field, count: :bytes, min: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at least %{count} byte(s)",
                   count: count, kind: :min, type: :binary, validation: :length}}
               ]
      end
    end

    property "adds an error if value has a length greater than `:max` when `:count` is `:bytes`" do
      check all(
              value <- string(:printable, min_length: 5),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = byte_size(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(data, field, count: :bytes, max: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should be at most %{count} byte(s)",
                   count: count, kind: :max, type: :binary, validation: :length}}
               ]
      end
    end
  end

  describe "validate_length/3 with lists as input" do
    property "adds an error if value is a list and does not exactly match `:is`" do
      check all(
              value <- list_of(term(), min_length: 2),
              field <- atom(:alphanumeric),
              wrong_length <- positive_integer()
            ) do
        data = Map.new([{field, value}])
        count = length(value)

        count =
          if count == wrong_length do
            count - 1
          else
            wrong_length
          end

        result = Dredd.validate_length(data, field, count: :bytes, is: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should have %{count} item(s)",
                   count: count, kind: :is, type: :list, validation: :length}}
               ]
      end
    end

    property "adds an error if value is a list with fewer items than `:min`" do
      check all(
              value <- list_of(term(), min_length: 1),
              field <- atom(:alphanumeric),
              excess_length <- positive_integer()
            ) do
        data = Map.new([{field, value}])
        count = length(value) + 1 + excess_length

        result = Dredd.validate_length(data, field, count: :bytes, min: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should have at least %{count} item(s)",
                   count: count, kind: :min, type: :list, validation: :length}}
               ]
      end
    end

    propery "adds an error if value is a list with more items than `:max`" do
      check all(
              value <- list_of(term(), min_length: 5),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        result = Dredd.validate_length(data, field, count: :bytes, max: count)

        assert %Dredd.Dataset{} = result
        assert result.valid? == false
        assert result.data == data

        assert result.errors == [
                 {field,
                  {"should have at most %{count} item(s)",
                   count: count, kind: :max, type: :list, validation: :length}}
               ]
      end
    end

    property "does not add an error if value's length matches `:is` exactly" do
      check all(
              value <- list_of(term(), min_length: 2),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = length(value)

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, is: count)
      end
    end

    property "does not add an error if value has a length greater than `:min`" do
      check all(
              value <- list_of(term(), min_length: 2),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])
        count = length(value)

        count =
          if count < 10 do
            count - 1
          else
            List.first(Enum.take(integer(1..(count - 2)), 1))
          end

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, min: count)
      end
    end

    property "does not add an error if value has a length less than `:max`" do
      check all(
              value <- list_of(term(), min_length: 2),
              field <- atom(:alphanumeric),
              excess_length <- positive_integer()
            ) do
        data = Map.new([{field, value}])
        count = length(value) + excess_length

        assert %Dredd.Dataset{
                 data: ^data,
                 errors: [],
                 valid?: true
               } = Dredd.validate_length(data, field, max: count)
      end
    end
  end

  describe "validate_length/3 with nonsupported types as input" do
    test "does not add an error if value is nil" do
      field = :field
      data = Map.new([{field, nil}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_length(data, field, is: 1)
    end

    test "does not add an error if value is an empty string" do
      field = :field
      data = Map.new([{field, ""}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_length(data, field, is: 1)
    end

    property "can correctly handle arbitrary data" do
      check all(
              value <- term(),
              field <- atom(:alphanumeric)
            ) do
        data = Map.new([{field, value}])

        if (is_binary(value) and value != "") or is_list(value) do
          assert %Dredd.Dataset{
                   data: ^data,
                   valid?: false,
                   errors: _list
                 } = Dredd.validate_length(data, field, is: -1)
        else
          assert %Dredd.Dataset{
                   data: ^data,
                   errors: [],
                   valid?: true
                 } = Dredd.validate_length(data, field, is: -1)
        end
      end
    end
  end

  describe "validate_length/3" do
    test "uses a custom error message when provided" do
      field = :field
      value = "é"
      message = "message"
      data = Map.new([{field, value}])
      count = length(String.graphemes(value)) + 1

      assert %Dredd.Dataset{
               data: ^data,
               errors: [
                 {^field,
                  {^message, count: ^count, kind: :is, type: :string, validation: :length}}
               ],
               valid?: false
             } = Dredd.validate_length(data, field, is: count, message: message)
    end
  end
end
