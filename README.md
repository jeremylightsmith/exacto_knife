# ExactoKnife

![Github Actions](https://github.com/jeremylightsmith/exacto_knife/actions/workflows/elixir.yml/badge.svg?branch=main)
[![Module Version](https://img.shields.io/hexpm/v/exacto_knife.svg)](https://hex.pm/packages/exacto_knife)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/exacto_knife/)
[![Total Download](https://img.shields.io/hexpm/dt/exacto_knife.svg)](https://hex.pm/packages/exacto_knife)
[![License](https://img.shields.io/hexpm/l/exacto_knife.svg)](https://github.com/jeremylightsmith/exacto_knife/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/jeremylightsmith/exacto_knife.svg)](https://github.com/jeremylightsmith/exacto_knife/commits/master)

Refactoring tools for elixir!

## Refactorings

### Refactoring: Sort aliases

```
> mix refactor sort_aliases [FILE]
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
> mix refactor expand_aliases [FILE]
```

Expand out all aliases in a file:

```elixir
alias Foo.Bar.Baz
alias Foo.Bar.Boom
```

----

### Refactoring: Consolidate aliases

```
> mix refactor consolidate_aliases [FILE]
```

Sort and combine all aliases in a file:

```elixir
alias Foo.Bar.{Baz, Boom}
```

----

### Refactoring: Rename Variable

```
> mix refactor rename [FILE] [LINE] [COLUMN]
```

Renames a variable (currently this is a fairly naive implementation - issues welcome!)


More to come...

----

## Running against an entire codebase

Find is your friend

```
> find lib -type f -name "*.ex*" | xargs -n1 mix refactor sort_aliases
```

## Installation

Exacto Knife can be installed by adding `exacto_knife` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exacto_knife, "~> 0.1.4"}
  ]
end
```

Docs can be found at <https://hexdocs.pm/exacto_knife>.

----

## Contributing

* Clone the repo
* Write a failing test for your change
* Make sure all tests pass
* Submit a PR
* We all win!!!

### Releasing

* bump the version in `mix.exs` and `README.md`
* commit
* make sure github ci passes
* run `mix hex.publish`

### Links

* [Elixir Syntax Reference](https://hexdocs.pm/elixir/syntax-reference.html#the-elixir-ast) has a good intro to the AST.
* [Sourceror Docs](https://hexdocs.pm/sourceror/readme.html) are pretty great, understanding their zippers is essential.
* [AST Ninja](https://ast.ninja/) will show you the ast for specific code.