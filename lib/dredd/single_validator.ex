defmodule Dredd.SingleValidator do
  @moduledoc """
  Base module for all single value validators. For convenience it provides a
  wrapping `validate` function that ensures that all single-value validators
  are chainable and also do an early abort in case a previous validation did
  already fail.

  If you want to implement you own single-value validator you only have to
  implement the `validate` function that will already receive the data wrapped in
  a `SingleResult` and has to return a `SingleResult`.
  """

  alias Dredd.SingleResult

  @callback validate(SingleResult.t(), keyword()) :: SingleResult.t()

  @spec dispatch(module(), any(), keyword()) :: SingleResult.t()
  def dispatch(module, result, opts \\ [])

  def dispatch(_module, %SingleResult{valid?: false} = result, _opts) do
    result
  end

  def dispatch(module, %SingleResult{} = result, opts) do
    module.validate(result, opts)
  end

  def dispatch(module, data, opts) do
    module.validate(%SingleResult{data: data}, opts)
  end

  @spec error_result(any(), binary(), atom(), map()) :: SingleResult
  def error_result(data, message, validator, metadata) do
    %SingleResult{
      data: data,
      valid?: false,
      error: %Dredd.SingleError{
        validator: validator,
        message: message,
        metadata: metadata
      }
    }
  end

  defmacro __using__(_opts) do
    quote do
      alias Dredd.SingleValidator
      @behaviour SingleValidator

      import SingleValidator, only: [error_result: 4]

      @spec call(any(), keyword()) :: SingleResult.t()
      def call(data, opts \\ []) do
        SingleValidator.dispatch(__MODULE__, data, opts)
      end
    end
  end
end
