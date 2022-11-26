defmodule Dredd.Validators.Required do
  @moduledoc false

  @default_message "can't be blank"

  def call(dataset, fields, opts \\ []) do
    dataset = Dredd.Dataset.new(dataset)

    fields = List.wrap(fields)

    message = Keyword.get(opts, :message, @default_message)

    Enum.reduce(fields, dataset, fn field, acc ->
      trimmed_value =
        dataset.data
        |> Map.get(field)
        |> maybe_trim_value(Keyword.get(opts, :trim?, true))

      if trimmed_value in [nil, ""] do
        Dredd.add_error(acc, field, message, validation: :required)
      else
        acc
      end
    end)
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
