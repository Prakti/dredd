defmodule Dredd.Validators.FormatTest do
  use ExUnit.Case, async: true

  describe "validate_format/4" do
    test "adds an error if value does not match the provided format" do
      field = :field
      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{"has invalid format", validation: :format}]}],
               valid?: false
             } = Dredd.validate_format(data, field, ~r/\d/)
    end

    test "does not add an error if value does match the provided format" do
      field = :field
      value = "value"
      data = Map.new([{field, value}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_format(data, field, ~r/#{value}/)
    end

    test "uses a custom error message when provided" do
      field = :field
      message = "message"
      data = Map.new([{field, "value"}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{^message, validation: :format}]}],
               valid?: false
             } = Dredd.validate_format(data, field, ~r/\d/, message: message)
    end

    test "do not add an error if value is nil" do
      field = :field
      value = nil
      data = Map.new([{field, value}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_format(data, field, ~r/\d/)
    end

    test "do not add an error if value is a blank string" do
      field = :field
      value = ""
      data = Map.new([{field, value}])

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_format(data, field, ~r/\d/)
    end
  end
end
