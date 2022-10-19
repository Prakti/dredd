defmodule Dredd.Validators.Email do
  @moduledoc false

  @email_regex ~r/\S+@\S+.\S+/

  @default_message "is not a valid email address"

  def call(dataset, field, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = Map.get(dataset.data, field)

    message = Keyword.get(opts, :message, @default_message)

    if value == nil || is_email?(value) do
      dataset
    else
      Dredd.add_error(dataset, field, message, validation: :email)
    end
  end

  defp is_email?(value) do
    if is_binary(value) and String.valid?(value) do
      value =~ @email_regex
    else
      false
    end
  end
end
