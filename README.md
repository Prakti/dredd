# Dredd
Dredd judges data for you. It's a validator for a wide range of

datastructures. 
Started as a frok of [Justify][2] it's been rewritten to handle plain values
as well as deeply nested structures and return understandable
error-structures.

Following in the footsteps of [Ecto.Changeset][1], Dredd allows you to pipe
values into a series of validation functions using a simple and familiar API. No
schemas or casting required.

[1]: https://hexdocs.pm/ecto/Ecto.Changeset.html
[2]: https://github.com/malomohq/justify

### A Basic Example

```elixir
iex> Dredd.validate_type("this is not an integer", :integer)
%Dredd.Dataset{
  data: "this is not an integer",
  error: %Dredd.SingleError{
    validator: :type,
    message: "has invalid type",
    metadata: %{type: :integer}
  },
  valid?: false
}
```

As you can see this is a rather verbose output; but we believe that this can
come in handy in conjunction when you have to translate the error on the
user interface.

Each validation function will return a `%Dredd.Dataset{}` which can be
passed into the next function. If a validation error is encountered the dataset
will be marked as invalid and an error will be added to the struct. Each
validator behaves in a fail-fast manner. If the Dataset is already invalid
no further validation happens for any given value. As a tip: you should order your
validations by descending importance.

Errors are distinguished by type to allow traversal of nested structures by
matching against the struct type of the encountered error.

When validating single values a `%SingleError{}` is returned whenever it
fails.

## Validating Lists

To ramp up the complexits: you can validate all elements of a list by handing 
a validation function to `Dredd.validate_list`. 

### Simple List Example

This is how you would validate a list of strings. 

```elixir
iex> Dredd.validate_list(["string", -1, "string", 0], &Dredd.validate_type(&1, :string))
%Dredd.Dataset{
  data: ["string", -1, "string", 0],
  error: %Dredd.ListErrors{
    validator: :list,
    errors: %{
      1 => %Dredd.SingleError{
        validator: :type,
        message: "has invalid type",
        metadata: %{type: :string}
      },
      3 => %Dredd.SingleError{
        validator: :type,
        message: "has invalid type",
        metadata: %{type: :string}
      }
    }
  },
  valid?: false
}
```

In case of errors, `validate_list` returns a `%Dredd.Dataset{}` containing a
`%Dredd.ListError{}` or a `%Dredd.SimpleError{}` which in turn contains a 
map with `Dredd.SingleError{}` values stored unter their positions in the 
list. We hope that at this point the typing of the errors and the verbosity
help to understand at which point in the given datastructure the error 
actually occurred.

### Complex List Example

You can exploit the fact that cou can pipe the output of all validator
functions into the next one and compose chain together multiple values for
the elements of your list. 

```elixir
iex> item_validator = fn data ->
...>   Dredd.validate_required(data)
...>   |> Dredd.validate_type(:string)
...> end
iex> my_list = ["", -1, "foo"]
["", -1, "foo"]
iex> Dredd.validate_list(my_list, item_validator)
%Dredd.Dataset{
  data: ["", -1, "foo"],
  error: %Dredd.ListErrors{
    validator: :list,
    errors: %{
      0 => %Dredd.SingleError{
        validator: :required,
        message: "can't be blank",
        metadata: %{}
      },
      1 => %Dredd.SingleError{
        validator: :type,
        message: "has invalid type",
        metadata: %{type: :string}
      }
    }
  },
  valid?: false
}
```

### Handling Non-Lists

In case `Dredd.validate_list` is handed anything but a list, it will return
a `%Dredd.SingleError{}` indicating that the value is of wrong type:

```elixir
iex> Dredd.validate_list(100, &Dredd.validate_required(&1))
%Dredd.Dataset{
  data: 100,
  error: %Dredd.SingleError{
    validator: :type,
    message: "has invalid type",
    metadata: %{type: :list}
  },
  valid?: false
}
```

## Validating Structs

You can validate fields of a struct or map using the
`Dredd.validate_map/2` function.

### Struct Example



## Copyright and License

Copyright (c) 2022 Marcus Autenrieth

Dredd is licensed under the MIT License, see LICENSE.md for details.
