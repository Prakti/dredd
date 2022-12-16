defmodule Dredd.Validators.ObjectTest do
  use ExUnit.Case, async: true

  # TODO: 2022-12-15 - Redesign test for Stcut Validator

  describe "validate_object/3" do
    # test "adds an error if a sub-object is invalid" do
    #   field = :field
    #   sub_field_a = :sub_field_a
    #   sub_field_b = :sub_field_b
    #
    #   data =
    #     Map.new([
    #       {field,
    #        Map.new([
    #          {sub_field_a, ""},
    #          {sub_field_b, ""}
    #        ])}
    #     ])
    #
    #   validator = fn sub_object ->
    #     sub_object
    #     |> Dredd.validate_required(sub_field_a)
    #     |> Dredd.validate_required(sub_field_b)
    #   end
    #
    #   assert %Dredd.Dataset{
    #            data: ^data,
    #            errors: [
    #              {^field,
    #               [
    #                 {^sub_field_a, [{_, _}]},
    #                 {^sub_field_b, [{_, _}]}
    #               ]}
    #            ],
    #            valid?: false
    #          } = Dredd.validate_object(data, field, validator)
    # end
    #
    # test "does not add an error if a sub-object is valid" do
    #   field = :field
    #   sub_field_a = :sub_field_a
    #   sub_field_b = :sub_field_b
    #
    #   data =
    #     Map.new([
    #       {field,
    #        Map.new([
    #          {sub_field_a, "foo"},
    #          {sub_field_b, "bar"}
    #        ])}
    #     ])
    #
    #   fun = fn sub_object ->
    #     sub_object
    #     |> Dredd.validate_required(sub_field_a)
    #     |> Dredd.validate_required(sub_field_b)
    #   end
    #
    #   assert %Dredd.Dataset{
    #            data: ^data,
    #            errors: [],
    #            valid?: true
    #          } = Dredd.validate_object(data, field, fun)
    # end
  end
end
