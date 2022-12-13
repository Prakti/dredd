defmodule Dredd.Validators.UUID do
  @moduledoc false

  @uuid_regex ~r/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  @default_message "is not a valid uuid"

  use Dredd.SingleValidator

  def validate(result, _opts) do
    data = result.data

    if data == nil || is_uuid?(data) do
      result
    else
      error_result(data, @default_message, :uuid, %{})
    end
  end

  defp is_uuid?(value) do
    if is_binary(value) do
      value =~ @uuid_regex
    else
      false
    end
  end
end
