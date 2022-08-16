defmodule Dredd.Validators.EmbedTest do
  use ExUnit.Case, async: true

  describe "validate_embed/3" do
    test "adds an error if an embedded map is invalid" do
      field = :field
      embed_field = :embed_field
      message = "message"
      keys = [validation: :custom]

      data = Map.new([{field, Map.new([{embed_field, false}])}])

      fun = fn _value -> Dredd.add_error(%Dredd.Dataset{}, embed_field, message, keys) end

      assert %Dredd.Dataset{
               data: ^data,
               errors: [{^field, [{^embed_field, {^message, ^keys}}]}],
               valid?: false
             } = Dredd.validate_embed(data, field, fun)
    end

    test "adds an error if an embedded list is invalid" do
      field = :field

      embed_field = :embed_field
      message = "message"
      keys = [validation: :custom]

      embed_data = Map.new([{embed_field, false}])
      data = Map.new([{field, [embed_data, embed_data]}])

      fun = fn _value -> Dredd.add_error(%Dredd.Dataset{}, embed_field, message, keys) end

      assert %Dredd.Dataset{
               data: ^data,
               errors: [
                 {^field,
                  [[{^embed_field, {^message, ^keys}}], [{^embed_field, {^message, ^keys}}]]}
               ],
               valid?: false
             } = Dredd.validate_embed(data, field, fun)
    end

    test "does not add an error if the embedded value is valid" do
      field = :field

      embed_field = :embed_field
      embed_data = Map.new([{embed_field, true}])
      data = Map.new([{field, embed_data}])

      fun = fn value -> value end

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_embed(data, field, fun)
    end

    test "does not add an error if value is `nil`" do
      field = :field

      embed_field = :embed_field
      message = "message"
      keys = [validation: :custom]

      data = Map.new([{field, nil}])

      fun = fn _value -> Dredd.add_error(%Dredd.Dataset{}, embed_field, message, keys) end

      assert %Dredd.Dataset{
               data: ^data,
               errors: [],
               valid?: true
             } = Dredd.validate_embed(data, field, fun)
    end
  end
end
