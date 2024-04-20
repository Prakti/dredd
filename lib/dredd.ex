defmodule Dredd do
  @moduledoc """
  Dredd judges data for you. It's a validator for a wide range of
  datastructures.

  See the [README][1] for a detailed guide.

  [1]: readme.html
  """

  @type number_t ::
          :float
          | :integer
          | :non_neg_integer
          | :pos_integer

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
      metadata: %{kind: :type}
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
      metadata: %{expected: true, kind: :value}
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
  the length of the string either as codepoints or graphemes.

  ## Options
  * `:is` - exact required length of a string
  * `:min` - minimal required length of a string
    (should not be used together with `is`)
  * `:max` - maximal allowed length of a string
    (should not be used together with `is`)
  * `:count` - can be `:codepoints` or `:graphemes`.
     Defaults to `:graphemes`
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
  iex> Dredd.validate_string("", min_length: 5)
  %Dredd.Dataset{
    data: "",
    error: %Dredd.SingleError{
      validator: :string,
      message: "should be at least %{count} character(s)",
      metadata: %{count: 5, kind: :min_length}
    },
    valid?: false
  }
  ```
  """
  @spec validate_string(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_string(dataset, opts \\ []),
    to: Dredd.Validators.String,
    as: :call

  @doc """
  Validates the given values binaries. Optionally also validates the length of the binary either .

  ## Options
  * `:is` - exact required length of a binary
  * `:min` - minimal required length of a binary
    (should not be used together with `is`)
  * `:max` - maximal allowed length of a binary
    (should not be used together with `is`)
  * `:type_message` - error message in case the type is wrong;
    defaults to "is not a binary"
  * `:is_message` - error message in case the exact length is wrong
     defaults to "should be %{count} bytes(s)"
  * `:min_message` - error message in case the length is too short
    defaults to "should be at least %{count} bytes(s)"
  * `:max_message` - error message in case the length is too long
    defaults to "should be at "should be at most %{count} bytes(s)"
  """
  @spec validate_binary(any, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_binary(dataset, opts \\ []),
    to: Dredd.Validators.Binary,
    as: :call

  @type single_validator_fun :: (any() -> Dredd.Dataset.t())

  @doc """
  Applies a validator function to a each element of a list contained in a field.

  ## Options
  * `:is` - exact required length of a list
  * `:min` - minimal required length of a list 
    (should not be used together with `is`)
  * `:max` - maximal allowed length of a list
    (should not be used together with `is`)
  * `:type_message` - error message in case the type is wrong;
    defaults to "is not a list"
  * `:is_message` - error message in case the exact length is wrong
     defaults to "should be %{count} item(s)"
  * `:min_message` - error message in case the length is too short
    defaults to "should be at least %{count} item(s)"
  * `:max_message` - error message in case the length is too long
    defaults to "should be at "should be at most %{count} item(s)"

  ## Example
  ```elixir
  ```
  """
  @spec validate_list(any(), single_validator_fun(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_list(dataset, validator, opts \\ []),
    to: Dredd.Validators.List,
    as: :call

  @type field_spec :: single_validator_fun() | {:optional, single_validator_fun()}

  @type validator_map :: %{any() => field_spec()}

  @doc """
  Validates the structure of a Map, Keyword List, Struct or anything else
  that supports the Access behaviour and whose structure can be represented
  by a map.

  ## Options
  * `message` - error message in case the type-check fails
     defaults to: "is not a map"

  ## Example
  ```elixir
  iex> value = %{ field_a: 10, field_b: "foo" }
  %{field_a: 10, field_b: "foo"}
  iex> validator_map = %{
  ...>   field_a: &Dredd.validate_string/1,
  ...>   field_b: fn data -> Dredd.validate_number(data, :integer) end
  ...>}
  iex> Dredd.validate_map(value, validator_map)
  %Dredd.Dataset{
    data: %{field_a: 10, field_b: "foo"},
    error: %Dredd.MapErrors{
      validator: :map,
      errors: %{
        field_a: %Dredd.SingleError{
          validator: :string,
          message: "is not a string",
          metadata: %{kind: :type}
        },
        field_b: %Dredd.SingleError{
          validator: :number,
          message: "has incorrect numerical type",
          metadata: %{kind: :integer}
        }
      }
    },
    valid?: false
  }
  ```
  """
  @spec validate_map(any(), validator_map(), Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_map(dataset, validator_map, opts \\ []),
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
  Validates that the value of a field is a number.

  Supported types:

  * `:float`
  * `:integer`
  * `:non_neg_integer`
  * `:pos_integer`

  ## Options

  * ´predicate` - function of type `(any -> boolean)`
  * `:type_message` - error message in case the type is wrong.
    Defaults to "has incorrect numerical type"
  * `:predicate_message` - error message in case the predicate check fails.
    Defaults to "violates the given predicate"
  """
  @spec validate_number(any, number_t, Keyword.t()) :: Dredd.Dataset.t()
  defdelegate validate_number(dataset, type, opts \\ []),
    to: Dredd.Validators.Number,
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

  @doc """
  This is a convenience function in case you want to write your own
  validators. It will set the `valid?` flag of the given `Dredd.Dataset` to false.
  It will also create a `Dredd.SingleError` structure with the given values
  and assing it to the `error` field of the `Dredd.Dataset`.
  """
  @spec set_single_error(Dredd.Dataset.t(), String.t(), atom(), map()) :: Dredd.Dataset.t()
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
