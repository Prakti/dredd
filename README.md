# Dredd
Dredd judges your data. It can validate arbitrary Elixir data with arbitrary deep nesting.


[![Build Status](https://github.com/prakti/dredd/workflows/ci/badge.svg)](https://github.com/prakti/dredd/actions) ![Hex.pm Version](https://img.shields.io/hexpm/v/dredd) [![Static Badge](https://img.shields.io/badge/hex-docs-green)](https://hexdocs.pm/dredd/readme.html)

Started as a fork of [Justify][2], dredd is a total rewrite to handle plain values
as well as deeply nested structures and return parseable error-structures.

Similar to [Ecto.Changeset][1], Dredd does not use a schema and a lot of metaprogramming magic.
Everything is done by composing or piping functions. Dredd excels in use-cases, where you want
to either avoid Ecto as a dependency, and/or where you want to validate deeply nested datastructures.

Dredd boasts an extensive test-suite, using property-based tests to verify its capabilities across
all possible input data. There should only be a very small amount of unspecified behaviour in Dredd.

[1]: https://hexdocs.pm/ecto/Ecto.Changeset.html
[2]: https://github.com/malomohq/justify

Please see the [Changelog](changelog.html) for what has changed in the latest release.

### A Basic Example

```elixir
iex> Dredd.validate_number("this is not a number", :integer)
%Dredd.Dataset{
  data: "this is not a number",
  error: %Dredd.SingleError{
    validator: :number,
    message: "has incorrect numerical type",
    metadata: %{kind: :integer}
  },
  valid?: false
}
```

As you can see this is a rather verbose output; but we believe that this can
come in handy in conjunction when you have to translate the error on the
user interface.

Each validation function will return a `Dredd.Dataset` which can be
passed into the next function. If a validation error is encountered the dataset
will be marked as invalid and an error will be added to the struct. Each
validator behaves in a fail-fast manner. If the Dataset is already invalid
no further validation happens for any given value. As a tip: you should order your
validations by descending importance.

Errors are distinguished by type to allow traversal of nested structures by
matching against the struct type of the encountered error.

When validating single values a `Dredd.SingleError` is returned whenever it
fails.

## Validating Lists

To ramp up the complexity: you can validate all elements of a list by handing
a validation function to `Dredd.validate_list/3`.

### Simple List Example

This is how you would validate a list of strings.

```elixir
iex(2)> Dredd.validate_list(["string", -1, "string", 0], &Dredd.validate_string/1)
%Dredd.Dataset{
  data: ["string", -1, "string", 0],
  error: %Dredd.ListErrors{
    validator: :list,
    errors: %{
      1 => %Dredd.SingleError{
        validator: :string,
        message: "is not a string",
        metadata: %{kind: :type}
      },
      3 => %Dredd.SingleError{
        validator: :string,
        message: "is not a string",
        metadata: %{kind: :type}
      }
    }
  },
  valid?: false
}
```

If the list does not match given length requirements or the given data is not a list, the
returned `Dredd.Dataset` will be invalid and contain a `Dredd.SingleError`.

In case an element of the list is invalid, the returned `Dredd.Dataset` will
contain `Dredd.ListErrors` with its `errors` field containing a map. The keys
of that map are the indices of the values for which validation failed. The
values of that map are `Dredd.SingleError`, `Dredd.ListErrors` or
`Dredd.MapErrors` depending on the given validator for the list items.

This distinction is meant to help with parsing the errors of nested validations.

### Complex List Example

You can exploit the fact that you can pipe the output of all validator
functions into the next one and compose chain together multiple values for
the elements of your list.

```elixir
iex> item_validator = fn data ->
...>   Dredd.validate_string(data)
...>   |> Dredd.validate_email()
...> end
iex> Dredd.validate_list(["foo", "foo@bar.com"], item_validator)
%Dredd.Dataset{
  data: ["foo", "foo@bar.com"],
  error: %Dredd.ListErrors{
    validator: :list,
    errors: %{
      0 => %Dredd.SingleError{
        validator: :email,
        message: "is not a valid email address",
        metadata: %{}
      }
    }
  },
  valid?: false
}
```

### Handling Non-Lists

In case `Dredd.validate_list/3` is handed anything but a list, it will return
a `Dredd.SingleError` indicating that the value is of wrong type:

```elixir
iex> Dredd.validate_list(100, &Dredd.validate_email/1)
%Dredd.Dataset{
  data: 100,
  error: %Dredd.SingleError{
    validator: :list,
    message: "is not a list",
    metadata: %{kind: :type}
  },
  valid?: false
}
```

## Validating Structs

You can validate fields of a struct or map using the `Dredd.validate_map/2` function.

### Simple Struct Example
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

In case of errors the output of `Dredd.validate_map\3` is quite similar to that
of `Dredd.validate_list\3`. 

If the give value is not a valid map the `Dredd.Dataset` will contain a
`Dredd.SingleError`. 


If the validations on field-level failed the `Dredd.Dataset` will contain `Dredd.MapErrors`.
The keys in that map are the fieldnames of the invalid fields. The values in the map can be
`Dredd.SingleError`, `Dredd.ListErrors` or `Dredd.MapErrors` depending on the
validator of that field.

This distinction is meant to help with parsing the errors of nested validations.

### Nested Example

```elixir
iex> email_list_validator = fn data ->
...>   Dredd.validate_list(data, &Dredd.validate_email/1)
...> end
# Function<...>
iex> validate_embedded_map = fn data ->
...>   validator_map = %{
...>     email_list: email_list_validator,
...>     number: &Dredd.validate_number(&1, :integer)
...>   }
...>   Dredd.validate_map(data, validator_map)
...> end
# Function<...>
iex> map_list_validator = fn data ->
...>   Dredd.validate_list(data, validate_embedded_map)
...> end
# Function<...>
iex> validator_map = %{
...>   map_list: map_list_validator,
...>   str_field: &Dredd.validate_string/1
...> }
%{
  map_list: #Function<...>,
  str_field: &Dredd.validate_string/1
}
iex> value = %{
...>   map_list: [
...>    %{email_list: ["foo@bar.com", "bang@baz.net"], number: 10 },
...>    %{email_list: ["foo@bar.com", "blubb"], number: 20 }
...>   ],
...>   str_field: "bar"
...> }
%{
  map_list: [
    %{email_list: ["foo@bar.com", "bang@baz.net"], number: 10},
    %{email_list: ["foo@bar.com", "blubb"], number: 20}
  ],
  str_field: "bar"
}
iex> Dredd.validate_map(value, validator_map)
%Dredd.Dataset{
  data: %{
    map_list: [
      %{email_list: ["foo@bar.com", "bang@baz.net"], number: 10},
      %{email_list: ["foo@bar.com", "blubb"], number: 20}
    ],
    str_field: "bar"
  },
  error: %Dredd.MapErrors{
    validator: :map,
    errors: %{
      map_list: %Dredd.ListErrors{
        validator: :list,
        errors: %{
          1 => %Dredd.MapErrors{
            validator: :map,
            errors: %{
              email_list: %Dredd.ListErrors{
                validator: :list,
                errors: %{
                  1 => %Dredd.SingleError{
                    validator: :email,
                    message: "is not a valid email address",
                    metadata: %{}
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  valid?: false
}
```

In the example above, the second email in the list of the second sub-map in the
`map_list` field is invalid. Even with all the extra information the output is
quite confusing. That's the primary reason we've added all the extra type information.
With that you can pattern match against the `struct` type and have a fighting chance
at successfully traversing the data.

## Copyright and License
 
Copyright (c) 2022 Marcus Autenrieth

Dredd is licensed under the MIT License, see LICENSE.md for details.
