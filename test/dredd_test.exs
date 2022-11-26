defmodule DreddTest do
  use ExUnit.Case, async: true

  doctest Dredd

  describe "add_error/4" do
    test "adds an error to the dataset" do
      field = :field
      message = "message"
      keys = [key: "value"]

      dataset = Dredd.add_error(%Dredd.Dataset{}, field, message, keys)

      assert %Dredd.Dataset{errors: [{^field, [{^message, ^keys}]}], valid?: false} = dataset
      assert %Dredd.Dataset{errors: [{^field, [{^message, ^keys}]}], valid?: false} = dataset
    end
  end

  describe "validate_type/4" do
    test "adds an error if value does not match type :boolean" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :boolean}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :boolean)
    end

    test "adds an error if value does not match type :float" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :float}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :float)
    end

    test "adds an error if value does not match type :integer" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :integer}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :integer)
    end

    test "adds an error if value does not match type :non_neg_integer" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [
                 {^field, [{"has invalid type", validation: :type, type: :non_neg_integer}]}
               ],
               valid?: false
             } = Dredd.validate_type(data, field, :non_neg_integer)
    end

    test "adds an error if value is -1 for type :non_neg_integer" do
      field = :field

      data = Map.new([{field, -1}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [
                 {^field, [{"has invalid type", validation: :type, type: :non_neg_integer}]}
               ],
               valid?: false
             } = Dredd.validate_type(data, field, :non_neg_integer)
    end

    test "adds an error if value does not match type :pos_integer" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :pos_integer}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :pos_integer)
    end

    test "adds an error if value is 0 for type :pos_integer" do
      field = :field

      data = Map.new([{field, 0}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :pos_integer}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :pos_integer)
    end

    test "adds an error if value is -1 for type :pos_integer" do
      field = :field

      data = Map.new([{field, -1}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :pos_integer}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :pos_integer)
    end

    test "adds an error if value does not match type :string" do
      field = :field

      data = Map.new([{field, 0}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid type", validation: :type, type: :string}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :string)
    end

    test "raises an ArgumentError if type is not recognized" do
      field = :field

      data = Map.new([{field, "value"}])

      assert_raise ArgumentError, fn -> Dredd.validate_type(data, field, :nope) end
    end

    test "does not add an error if value matches type :boolean" do
      field = :field

      data = Map.new([{field, true}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :boolean)
    end

    test "does not add an error if value matches type :float" do
      field = :field

      data = Map.new([{field, 1.0}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :float)
    end

    test "does not add an error if value matches type :integer" do
      field = :field

      data = Map.new([{field, 1}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :integer)
    end

    test "does not add an error if value matches type :non_neg_integer" do
      field = :field

      data = Map.new([{field, 0}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :non_neg_integer)
    end

    test "does not add an error if value matches type :pos_integer" do
      field = :field

      data = Map.new([{field, 1}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :pos_integer)
    end

    test "does not add an error if value matches type :string" do
      field = :field

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_type(data, field, :string)
    end

    test "uses a custom error message when provided" do
      field = :field
      message = "message"

      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{^message, validation: :type, type: :boolean}]}],
               valid?: false
             } = Dredd.validate_type(data, field, :boolean, message: message)
    end
  end
end
