defmodule Dredd.Validators.ListTest do
  @moduledoc false

  use ExUnit.Case, async: true

  # TODO: 2022-12-15 - Rework List Test for new ListValidator

  describe "validate_list" do
    # test "adds errors for invalid values in a given list" do
    #   field = :field
    #   data = Map.new([{field, ["string", -1, "string", 0]}])
    #
    #   validator = fn data, idx ->
    #     Dredd.validate_type(data, idx, :string)
    #   end
    #
    #   assert %Dredd.Dataset{
    #            data: ^data,
    #            error: [
    #              {^field,
    #               [
    #                 {
    #                   [
    #                     {1, [{_, _}]},
    #                     {3, [{_, _}]}
    #                   ],
    #                   [validation: :list]
    #                 }
    #               ]}
    #            ],
    #            valid?: false
    #          } = Dredd.validate_list(data, field, validator)
    # end
  end
end
