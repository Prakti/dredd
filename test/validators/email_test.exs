defmodule Dredd.Validators.EmailTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Dredd.Dataset

  @username_chars [?a..?z] ++ [?A..?Z] ++ [?0..?9]

  defp build_email_name(fragments, separators) do
    bind(fragments, fn [first | frags] ->
      if frags != [] do
        rest =
          Stream.zip(separators, frags)
          |> Stream.map(&Tuple.to_list/1)
          |> Enum.concat()
          |> Enum.join()

        constant(first <> rest)
      else
        constant(first)
      end
    end)
  end

  def email do
    separator = member_of(["-", "_", "."])
    separators = list_of(separator, max_length: 4)
    fragments = string(@username_chars, min_length: 1, max_length: 20)

    name =
      bind(separators, fn seps ->
        fragment_count = Enum.count(seps) + 1
        fragment_list = list_of(fragments, length: fragment_count)

        build_email_name(fragment_list, seps)
      end)

    domain = string([?a..?z], min_length: 2, max_length: 10)

    email_tuple = tuple({name, name, domain})

    bind(email_tuple, fn {name, domain, tld} ->
      constant(name <> "@" <> domain <> "." <> tld)
    end)
  end

  def invalid_email do
    filter(term(), fn data ->
      not (is_binary(data) and String.valid?(data) and
             (data =~ ~r/\S+@\S+.\S+/ or data == ""))
    end)
  end

  describe "validate_email data from a map" do
    property "correctly validates emails given in a map" do
      check all(email <- email()) do
        data = email

        result = Dredd.validate_email(email)

        assert result.data == data
        assert result.valid? == true
        assert result.error == nil
      end
    end

    property "rejects everything that is not a valid email given in a map" do
      check all(no_email <- invalid_email()) do
        data = no_email

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: false,
                 error: %Dredd.SingleError{
                   validator: :email,
                   message: "is not a valid email address",
                   metadata: %{}
                 }
               } = Dredd.validate_email(data)
      end
    end
  end

  describe "validate_email data from a Dataset" do
    property "correctly validates emails given in a Dataset" do
      check all(email <- email()) do
        data = email
        dataset = Dataset.new(data)

        result = Dredd.validate_email(dataset)

        assert result.data == data
        assert result.valid? == true
        assert result.error == nil
      end
    end

    property "rejects everything that is not a valid email given in a Dataset" do
      check all(no_email <- invalid_email()) do
        data = no_email
        dataset = Dataset.new(data)

        assert %Dredd.Dataset{
                 data: ^data,
                 valid?: false,
                 error: %Dredd.SingleError{
                   validator: :email,
                   message: "is not a valid email address",
                   metadata: %{}
                 }
               } = Dredd.validate_email(dataset)
      end
    end
  end
end
