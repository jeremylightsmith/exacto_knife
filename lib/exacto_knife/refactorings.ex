defmodule ExactoKnife.Refactorings do
  @moduledoc """
  These are the top level refactorings that exacto knife publishes.

  These functions take and return an AST node parsed w/ Sourceror.
  """

  alias ExactoKnife.Refactorings.OptimizeAliases
  alias ExactoKnife.Refactorings.Rename
  alias Sourceror.Zipper, as: Z

  # these methods all take a quoted source and return the same

  def sort_aliases(quoted) do
    Z.zip(quoted)
    |> Z.traverse(&OptimizeAliases.sort_aliases/1)
    |> Z.root()
  end

  def consolidate_aliases(quoted) do
    sort_aliases(quoted)
    |> Z.zip()
    |> Z.traverse(&OptimizeAliases.consolidate_aliases/1)
    |> Z.root()
  end

  def expand_aliases(quoted) do
    Z.zip(quoted)
    |> Z.traverse(&OptimizeAliases.expand_aliases/1)
    |> Z.root()
  end

  def rename(quoted, sel, name) do
    Z.zip(quoted)
    |> Rename.rename(sel, name)
    |> Z.root()
  end
end
