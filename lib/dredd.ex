defmodule Dredd do
  @moduledoc """
  Dredd judges data for you. It's a validator for a wide range of
  datastructures. 

  See the [README][1] for a detailed guide.

  [1]: readme.html
  """

  @type type_t ::
          :float
          | :integer
          | :non_neg_integer
          | :pos_integer
          | :string
          | :list
          | :struct
          | :map

  @doc """
  Validates the given values is of type boolean. Optionally also validates
  against a specific boolean value.

  ## Options
  * `:is` - the expected value (`true`|`false`)
  * `:wrong_type_message` - error message, defaults to "is not a boolean"
  * `:wrong_value_message` - error message, defaults to "expected value: %{expected}"

  ## Examples
  Simple case with data of invalid type:
  ```elixir
  iex> Dredd.validate_boolean('foo')
  %Dredd.Dataset{
    data: 'foo',
    error: %Dredd.SingleError{
      validator: :boolean,
      message: "is not a boolean",
      metadata: %{}
    },
    valid?: false
  }
  ```

  Simple case with valid boolean type:
  ```elixir
  iex> Dredd.validate_boolean(true)
  %Dredd.Dataset{data: true, error: nil, valid?: true}
  ```

  Special invalid case with optional expected value:
  ```elixir
  iex> Dredd.validate_boolean(false, is: true)
  %Dredd.Dataset{
    data: false,
    error: %Dredd.SingleError{
      validator: :boolean,
      message: "expected value: %{expected}",
      metadata: %{expected: true}
    },
    valid?: false
  }
  ```
  """
  @spec validate_boolean(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_boolean(dataset, opts \\ []),
    to: Dredd.Validators.Boolean,
    as: :call

  @doc """
  Validates the given values is of type string. Optionally also validates
  the length of the string either as codepoints of graphemes.

  ## Options
  * `:is` - exact required length of a string
  * `:min` - minimal required length of a string
    (should not be used together with `is`)
  * `:max` - maximal allowed length of a string
    (should not be used together with `is`)
  * `:type_message` - error message in case the type is wrong; 
    defaults to "is not a string"
  * `:is_message` - error message in case the exact length is wrong
     defaults to "should be %{count} character(s)"
  * `:min_message` - error message in case the length is too short 
    defaults to "should be at least %{count} character(s)"
  * `:max_message` - error message in case the length is too long
    defaults to "should be at "should be at most %{count} character(s)"

  ## Examples
  Here's a simple data with invalid data:
  ```elixir
  iex> Dredd.validate_string(10)
  %Dredd.Dataset{
    data: 10,
    error: %Dredd.SingleError{
      validator: :string,
      message: "is not a string",
      metadata: %{kind: :type}
    },
    valid?: false
  }
  ```

  Here's an example with a string that is too short but has a length
  requirement:
  ```elixir
  iex> Dredd.validate_string("", min: 5)
  %Dredd.Dataset{
    data: "",
    error: %Dredd.SingleError{
      validator: :string,
      message: "should be at least %{count} character(s)",
      metadata: %{count: 5, kind: :min}
    },
    valid?: false
  }
  ```
  """
  @spec validate_string(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_string(dataset, opts \\ []),
    to: Dredd.Validators.String,
    as: :call

  @type single_validator_fun :: (any() -> Dredd.Dataset.t())

  @doc """
    Applies a validator function to a each element of a list contained in a field.

  ## TODO: 2022-11-20 - Write Example
  """
  @spec validate_list(any(), single_validator_fun()) :: Dredd.Dataset.t()
  defdelegate validate_list(dataset, validator),
    to: Dredd.Validators.List,
    as: :call

  @type field_spec :: single_validator_fun() | {:optional, single_validator_fun()}

  @type validator_map :: %{any() => field_spec()}

  @doc """
    Validates the structure of a Map, Keyword List, Struct or anything else
    that supports the Access behaviour and whose structure can be represented
    by a map.

  ## TODO: 2022-12-22 - Write Example
  """
  @spec validate_map(any(), validator_map()) :: Dredd.Dataset.t()
  defdelegate validate_map(dataset, validator_map),
    to: Dredd.Validators.Map,
    as: :call

  @doc """
  Validates the value for the given field is not contained within the provided
  enumerable.

  ## Options

  * `:message` - error message, defaults to "is reserved"
  """
  @spec validate_exclusion(any, Enum.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_exclusion(dataset, enum, opts \\ []),
    to: Dredd.Validators.Exclusion,
    as: :call

  @doc """
  Validates the value of the given field matches the provided format.

  ## Options

  * `:message` - error message, defaults to "has invalid format"
  """
  @spec validate_format(any, Regex.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_format(dataset, format, opts \\ []),
    to: Dredd.Validators.Format,
    as: :call

  @doc """
  Validates the value for the given field is contained within the provided
  enumerable.

  ## Options

  * `:message` - error message, defaults to "is invalid"
  """
  @spec validate_inclusion(any, Enum.t(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_inclusion(dataset, enum, opts \\ []),
    to: Dredd.Validators.Inclusion,
    as: :call

  @doc """
  Validates the length of a string or list.

  ## Options

  * `:count` - how to calculate the length of a string. Must be one of
    `:codepoints`, `:graphemes` or `:bytes`. Defaults to `:graphemes`.
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
  @spec validate_length(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_length(dataset, opts),
    to: Dredd.Validators.Length,
    as: :call

  @doc """
  Validates that the given value is neither null nor the empty string. 

  ## Optiions

  * `:trim?` - trim whitespaces if value is a string
  * `:message` - error message, defaults to "can't be blank"
  """
  @spec validate_required(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_required(dataset, opts \\ []),
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
  @spec validate_type(any, type_t, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_type(dataset, type, opts \\ []),
    to: Dredd.Validators.Type,
    as: :call

  @doc """
  Validates if the value of a given field is an email.

  NOTE: this validator is not RFC822 compliant. If you really need to be sure,
  send an email to that address.

  ## Options
  * `:message` - error message, default to "is not a valid email address"
  """
  @spec validate_email(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_email(dataset, opts \\ []),
    to: Dredd.Validators.Email,
    as: :call

  @doc """
  Validates if the value of a given field is a UUID.binary_to_string!

  ## Options

  * `:message` - error message, defaults to "is not a valid UUID"
  """
  @spec validate_uuid(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_uuid(dataset, opts \\ []),
    to: Dredd.Validators.UUID,
    as: :call

  @doc """
  Validates if the value of a given field is a UUID.binary_to_string!

  ## Options

  * `:message` - error message, defaults to "is not a valid UUID"
  """
  @spec validate_nanoid(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_nanoid(dataset, opts \\ []),
    to: Dredd.Validators.NanoID,
    as: :call

  def set_single_error(dataset, message, validator, metadata \\ %{}) do
    %Dredd.Dataset{
      dataset
      | valid?: false,
        error: %Dredd.SingleError{
          validator: validator,
          message: message,
          metadata: metadata
        }
    }
  end
end
