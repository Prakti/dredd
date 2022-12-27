defmodule Dredd.Validators.NanoIDTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.{
    Dataset,
    SingleError
  }

  def nanoid_gen(len) do
    string([?a..?z, ?A..?Z, ?0..?9, ?_, ?-], length: len)
  end

  describe "validate_nanoid" do
    property "correctly validates all nanoIDs given in a map" do
      check all(nanoid <- nanoid_gen(21)) do
        assert %Dataset{
                 data: ^nanoid,
                 valid?: true,
                 error: nil
               } = Dredd.validate_nanoid(nanoid)
      end
    end

    property "does not validate non-NanoID data given in a map" do
      check all(wrong_nanoid <- term()) do
        wrong_nanoid =
          if is_binary(wrong_nanoid) do
            # invalidate all string just to be sure
            wrong_nanoid <> "💩"
          else
            wrong_nanoid
          end

        assert %Dataset{
                 data: ^wrong_nanoid,
                 valid?: false,
                 error: %SingleError{
                   validator: :nanoid,
                   message: "is not a valid NanoID",
                   metadata: %{}
                 }
               } = Dredd.validate_nanoid(wrong_nanoid)
      end
    end

    property "does add an error if NanoID is shorter than required" do
      check all(nanoid <- nanoid_gen(21)) do
        length = String.length(nanoid) + 5

        assert %Dataset{
                 data: ^nanoid,
                 valid?: false,
                 error: %SingleError{
                   validator: :nanoid,
                   message: "expected NanoID length is %{count}",
                   metadata: %{kind: :length, count: ^length}
                 }
               } = Dredd.validate_nanoid(nanoid, length: length)
      end
    end

    property "does add an error if NanoID is longer than required" do
      check all(nanoid <- nanoid_gen(21)) do
        length = String.length(nanoid) - 5

        assert %Dataset{
                 data: ^nanoid,
                 valid?: false,
                 error: %SingleError{
                   validator: :nanoid,
                   message: "expected NanoID length is %{count}",
                   metadata: %{kind: :length, count: ^length}
                 }
               } = Dredd.validate_nanoid(nanoid, length: length)
      end
    end

    test "does an early abort if given dataset is already invalid" do
      data = %Dataset{
        data: nil,
        valid?: false,
        error: %SingleError{
          validator: :passthrough,
          message: "testing early abort",
          metadata: %{}
        }
      }

      assert %Dataset{
               data: nil,
               valid?: false,
               error: %SingleError{
                 validator: :passthrough,
                 message: "testing early abort",
                 metadata: %{}
               }
             } = Dredd.validate_nanoid(data)
    end

    test "allows setting a `type_message`" do
      message = "type message"

      assert %Dataset{
               data: nil,
               valid?: false,
               error: %SingleError{
                 validator: :nanoid,
                 message: ^message,
                 metadata: %{}
               }
             } = Dredd.validate_nanoid(nil, type_message: message)
    end

    test "allows setting a `length_message`" do
      data = "ABC123"
      message = "length message"

      assert %Dataset{
               data: ^data,
               valid?: false,
               error: %SingleError{
                 validator: :nanoid,
                 message: ^message,
                 metadata: %{kind: :length, count: 21}
               }
             } = Dredd.validate_nanoid(data, length_message: message)
    end

    test "adds an error if given value is `nil`" do
      assert %Dataset{
               data: nil,
               valid?: false,
               error: %SingleError{
                 validator: :nanoid,
                 message: "is not a valid NanoID",
                 metadata: %{}
               }
             } = Dredd.validate_nanoid(nil)
    end
  end
end
