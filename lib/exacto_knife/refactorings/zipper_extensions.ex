defmodule ExactoKnife.Refactorings.ZipperExtensions do
  @moduledoc """
  Extensions to sourceror's zipper functions.
  """

  alias Sourceror.Zipper, as: Z

  defdelegate zip(quoted), to: Z
  defdelegate next(z), to: Z

  def find_back(nil, _f), do: nil

  def find_back({node, _} = zipper, f) do
    if f.(node) do
      zipper
    else
      find_back(Z.prev(zipper), f)
    end
  end

  # returns node, or nil if there is no node/zipper
  def safe_node({n, _}), do: n
  def safe_node(nil), do: nil
end
