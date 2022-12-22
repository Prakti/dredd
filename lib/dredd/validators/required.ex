defmodule Dredd.Validators.Required do
  @moduledoc false

  alias Dredd.{
    Dataset,
    SingleError
  }

  @default_message "can't be blank"

  def call(%Dataset{valid?: false} = dataset, _opts) do
    dataset
  end

  def call(dataset, opts) do
    dataset = Dataset.new(dataset)

    message = Keyword.get(opts, :message, @default_message)
    trim? = Keyword.get(opts, :trim?, true)

    trimmed_value = maybe_trim_value(dataset.data, trim?)

    if trimmed_value in [nil, ""] do
      Dredd.set_single_error(dataset, message, :required)
    else
      dataset
    end
  end

  #
  # private
  #

  defp maybe_trim_value(nil, _does_not_matter) do
    nil
  end

  defp maybe_trim_value(value, true) when is_binary(value) do
    String.trim(value)
  end

  defp maybe_trim_value(value, _do_not_trim) do
    value
  end
end
