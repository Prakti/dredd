defmodule Dredd do
  @moduledoc """
  Dredd judges structs; it's a validator.

  Dredd was forked from [Justify][2]

  Inspired heavily by [Ecto.Changeset][1], Dredd allows you to pipe a plain map
  into a series of validation functions using a simple and familiar API. No
  schemas or casting required.

  [1]: https://hexdocs.pm/ecto/Ecto.Changeset.html
  [2]: https://github.com/malomohq/justify

  ### Example

  ```elixir
  dataset =
    %{email: "this_is_not_an_email"}
    |> Dredd.validate_required(:email)
    |> Dredd.validate_format(:email, ~r/\S+@\S+/)

  dataset.errors #=> [email: [{"has invalid format", validation: :format}]]
  dataset.valid? #=> false
  ```

  Each validation function will return a `Dredd.Dataset` struct which can be
  passed into the next function. If a validation error is encountered the dataset
  will be marked as invalid and an error will be added to the struct.

  ## Custom Validations

  You can provide your own custom validations using the `Dredd.add_error/4`
  function.

  ### Example

  ```elixir
  defmodule MyValidator do
    def validate_color(data, field, color) do
      dataset = Dredd.Dataset.new(data)

      value = Map.get(dataset.data, :field)

      if value == color do
        dataset
      else
        Dredd.add_error(dataset, field, "wrong color", validation: :color)
      end
    end
  end
  ```

  Your custom validation can be used as part of a validation pipeline.

  ### Example

  ```elixir
  dataset =
    %{color: "brown"}
    |> Dredd.validation_required(:color)
    |> MyValidator.validate_color(:color, "green")

  dataset.errors #=> [color: [{"wrong color", validation: :color}]]
  dataset.valid? #=> false
  ```

  ## Supported Validations

  * [`validate_acceptance/3`](https://hexdocs.pm/dredd/Dredd.html#validate_acceptance/3)
  * [`validate_confirmation/3`](https://hexdocs.pm/dredd/Dredd.html#validate_confirmation/3)
  * [`validate_embed/3`](https://hexdocs.pm/dredd/Dredd.html#validate_embed/3)
  * [`validate_exclusion/4`](https://hexdocs.pm/dredd/Dredd.html#validate_exclusion/4)
  * [`validate_format/4`](https://hexdocs.pm/dredd/Dredd.html#validate_format/4)
  * [`validate_inclusion/4`](https://hexdocs.pm/dredd/Dredd.html#validate_inclusion/4)
  * [`validate_length/3`](https://hexdocs.pm/dredd/Dredd.html#validate_length/3)
  * [`validate_required/3`](https://hexdocs.pm/dredd/Dredd.html#validate_required/3)
  * [`validate_type/4`](https://hexdocs.pm/dredd/Dredd.html#validate_type/4)
  """

  @type type_t ::
          :boolean
          | :float
          | :integer
          | :non_neg_integer
          | :pos_integer
          | :string

  @doc """
  Validates the given field has a value of `true`.

  ## Options

  * `:message` - error message, defaults to "must be accepted"
  """
  @spec validate_acceptance(map, atom, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_acceptance(dataset, field, opts \\ []),
    to: Dredd.Validators.Acceptance,
    as: :call

  @doc """
  Validates the value of a given field matches it's confirmation field.

  By default, the field will be checked against a field with the same name
  but appended with `_confirmation`. It’s possible to provide a custom field by
  providing a value to the `:confirmation_field` option.

  Note that if the confirmation field is `nil` or missing, by default, an error
  will not be added. You can specify that the confirmation field is required in
  the options (see below).

  ## Options

  * `:confirmation_field` - name of the field to validate against
  * `:message` - error message, defaults to "does not match"
  * `:required?` - whether the confirmation field must contain a value
  """
  @spec validate_confirmation(map, atom, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_confirmation(dataset, field, opts \\ []),
    to: Dredd.Validators.Confirmation,
    as: :call

  @doc """
  Applies a validator function to a field containing an struct itself.

  ## Example

      validator = fn(metadata) -> Dredd.validate_required(metadata, :key) end

      data = %{metadata: {value: "a value"}}

      validate_embed(data, :metadata, validator)
      #> %Dredd.Dataset{errors: [metadata: [{key: [{"can't be blank", validation: :required}] }] ], valid?: false}
  """
  @spec validate_object(map, atom, fun) :: Dredd.Dataset.t()
  defdelegate validate_object(dataset, field, validator),
    to: Dredd.Validators.Object,
    as: :call

  @doc """
    Applies a validator function to a each element of a list contained in a field.

  ## TODO: 2022-11-20 - Write Example
  """
  @spec validate_list(map, atom, fun) :: Dredd.Dataset.t()
  defdelegate validate_list(dataset, field, validator),
    to: Dredd.Validators.List,
    as: :call

  @doc """
  Validates the value for the given field is not contained within the provided
  enumerable.

  ## Options

  * `:message` - error message, defaults to "is reserved"
  """
  @spec validate_exclusion(map, atom, Enum.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_exclusion(dataset, field, enum, opts \\ []),
    to: Dredd.Validators.Exclusion,
    as: :call

  @doc """
  Validates the value of the given field matches the provided format.

  ## Options

  * `:message` - error message, defaults to "has invalid format"
  """
  @spec validate_format(map, atom, Regex.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_format(dataset, field, format, opts \\ []),
    to: Dredd.Validators.Format,
    as: :call

  @doc """
  Validates the value for the given field is contained within the provided
  enumerable.

  ## Options

  * `:message` - error message, defaults to "is invalid"
  """
  @spec validate_inclusion(map, atom, Enum.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_inclusion(dataset, field, enum, opts \\ []),
    to: Dredd.Validators.Inclusion,
    as: :call

  @doc """
  Validates the length of a string or list.

  ## Options

  * `:count` - how to calculate the length of a string. Must be one of
               `:codepoints`, `:graphemes` or `:bytes`. Defaults to
               `:graphemes`.
  * `:is` - the exact length match
  * `:min` - match a length greater than or equal to
  * `:max` - match a length less than or equal to
  * `:message` - error message, defaults to one of the following variants:
    * for strings
      * “should be %{count} character(s)”
      * “should be at least %{count} character(s)”
      * “should be at most %{count} character(s)”
    * for binary
      * “should be %{count} byte(s)”
      * “should be at least %{count} byte(s)”
      * “should be at most %{count} byte(s)”
    * for lists
      * “should have %{count} item(s)”
      * “should have at least %{count} item(s)”
      * “should have at most %{count} item(s)”
  """
  @spec validate_length(map, atom, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_length(dataset, field, opts),
    to: Dredd.Validators.Length,
    as: :call

  @doc """
  Validates that one or more fields is not empty. This means they are neither
  the empty string `""` nor they are `nil`.

  ## Options

  * `:message` - error message, defaults to "must be accepted"
  * `:trim?` - remove whitespace before validating, defaults to `true`
  """
  @spec validate_required(map, atom | [atom], Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_required(dataset, fields, opts \\ []),
    to: Dredd.Validators.Required,
    as: :call

  @doc """
  Validates that the value of a field is a specific type.

  Supported types:

  * `:boolean`
  * `:float`
  * `:integer`
  * `:non_neg_integer`
  * `:pos_integer`
  * `:string`

  ## Options

  * `:message` - error message, defaults to "has invalid type"
  """
  @spec validate_type(map, atom, type_t, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_type(dataset, field, type, opts \\ []),
    to: Dredd.Validators.Type,
    as: :call

  @doc """
  Validates if the value of a given field is an email.

  NOTE: this validator is not RFC822 compliant. If you really need to be sure,
  send an email to that address.

  ## Options
  * `:message` - error message, default to "is not a valid email address"
  """
  @spec validate_email(map, atom, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_email(dataset, field, opts \\ []),
    to: Dredd.Validators.Email,
    as: :call

  @doc """
  Validates if the value of a given field is a UUID.binary_to_string!

  ## Options

  * `:message` - error message, defaults to "is not a valid UUID"
  """
  @spec validate_uuid(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_uuid(data, opts \\ []),
    to: Dredd.Validators.UUID,
    as: :call

  @doc """
  Validates if the value of a given field is a UUID.binary_to_string!

  ## Options

  * `:message` - error message, defaults to "is not a valid UUID"
  """
  @spec validate_nanoid(map, atom, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_nanoid(dataset, field, opts \\ []),
    to: Dredd.Validators.NanoID,
    as: :call

  @doc """
  Validates if the given value is enumerable (i.e.: list, tuple or map, ...)
  Usually this should be used to validate lists of values.
  """
  @spec validate_enumerable(any(), Keyword.t()) :: Dredd.SingleResult.t()
  defdelegate validate_enumerable(value, opts \\ []),
    to: Dredd.Validators.Enumerable,
    as: :call


  @doc """
  Adds an error to the dataset.

  An optional keyword list can be used to provide additional contextual
  information about the error.
  """
  @spec add_error(Dredd.Dataset.t(), atom, String.t(), Keyword.t()) :: Dredd.Dataset.t()
  def add_error(dataset, field, message, keys \\ []) do
    put_error(dataset, field, {message, keys})
  end

  @doc false
  def put_error(dataset, field, error) when is_list(error) do
    errors =
      dataset
      |> Map.get(:errors)
      |> Keyword.update(field, error, &Enum.concat(&1, error))

    %{dataset | errors: errors, valid?: false}
  end

  @doc false
  def put_error(dataset, field, error) do
    errors =
      dataset
      |> Map.get(:errors)
      |> Keyword.update(field, [error], &Enum.concat(&1, [error]))

    %{dataset | errors: errors, valid?: false}
  end
end
