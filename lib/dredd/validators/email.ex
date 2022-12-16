defmodule Dredd.Validators.Email do
  @moduledoc false

  @email_regex ~r/\S+@\S+.\S+/

  @default_message "is not a valid email address"

  def call(dataset, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    value = dataset.data

    message = Keyword.get(opts, :message, @default_message)

    if value == nil || is_email?(value) do
      dataset
    else
      Dredd.set_single_error(dataset, message, :email)
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
