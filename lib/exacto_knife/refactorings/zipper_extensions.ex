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

  def find_variable_at_position(zipper, cursor) do
    zipper
    |> Z.find(fn
      {marker, meta, nil} when is_atom(marker) ->
        line = Keyword.get(meta, :line)
        col = Keyword.get(meta, :column)
        len = marker |> Atom.to_string() |> String.length()
        line == line(cursor) && col <= col(cursor) && col(cursor) <= col + len

      _ ->
        false
    end)
  end

  defp line(cursor), do: elem(cursor, 0)
  defp col(cursor), do: elem(cursor, 1)

  # returns node, or nil if there is no node/zipper
  def safe_node({n, _}), do: n
  def safe_node(nil), do: nil
end
