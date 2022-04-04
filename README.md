# ExactoKnife

Refactoring tools for elixir!

## Refactorings

### Refactoring: Sort aliases

```
mix refactor sort_aliases [FILE]
```

Sort all aliases in a file:

```elixir
alias Alpha
alias Alpha.Bravo
alias Alpha.Charlie
alias Delta
```

----

### Refactoring: Expand aliases

```
mix refactor expand_aliases [FILE]
```

Expand out all aliases in a file:

```elixir
alias Foo.Bar.Baz
alias Foo.Bar.Boom
```

----

### Refactoring: Consolidate aliases

```
mix refactor consolidate_aliases [FILE]
```

Sort and combine all aliases in a file:

```elixir
alias Foo.Bar.{Baz, Boom}
```

More to come...

----

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exacto_knife` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exacto_knife, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/exacto_knife>.

----

## Contributing

* Clone the repo
* Write a failing test for your change
* Make sure all tests pass
* Submit a PR
* We all win!!!

## Links

The [AST Ninja](https://ast.ninja/) is pretty helpful :)