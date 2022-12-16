defmodule Dredd.Validators.EnumerableTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  describe "validate_enumerable" do
    test "correctly validates lists" do
      test_list = ["a", "b", "c"]

      assert %Dataset{
               data: ^test_list,
               valid?: true,
               error: nil
             } = Dredd.validate_enumerable(test_list)
    end

    test "correctly rejects an integer value" do
      test_integer = 1000

      assert %Dataset{
               data: ^test_integer,
               valid?: false,
               error: %SingleError{
                 validator: :enumerable,
                 message: "is not enumerable",
                 metadata: %{}
               }
             } = Dredd.validate_enumerable(test_integer)
    end
  end
end
