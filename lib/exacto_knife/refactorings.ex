defmodule ExactoKnife.Refactorings do
  alias ExactoKnife.Refactorings.OptimizeAliases
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
end
