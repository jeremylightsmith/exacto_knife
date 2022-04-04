# ExFactor

Refactoring tools for elixir!

## Refactorings

### Sort aliases
### Expand aliases
### Consolidate aliases

Many more to come...

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_factor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_factor, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_factor>.

## Build

To recreate a runnable exec ppl can use to do the refactors:

`MIX_ENV=production mix escript.build`

## Using

After building, you can use ex_factor by calling:
```
./ex_factor [REFACTORING] [PATH]
```

e.g.
```
./ex_factor consolidate_aliases ../my/path/to/an/elixir/file.ex
```

## Contributing

* Clone the repo
* Write a failing test for your change
* Make sure all tests pass
* Submit a PR
* We all win!!!

## Links

The [AST Ninja](https://ast.ninja/) is pretty helpful :)