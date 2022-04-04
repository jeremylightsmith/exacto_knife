defmodule ExactoKnife.Refactorings.Node do
  @moduledoc """
  Helpers when dealing with AST nodes and node traversal
  """

  alias ExactoKnife.Refactorings.Node

  def get_in(tuple, [index | rest]) when is_tuple(tuple) and is_integer(index) do
    tuple
    |> elem(index)
    |> Node.get_in(rest)
  end

  def get_in(list, [index | rest]) when is_list(list) and is_integer(index) do
    list
    |> Enum.at(index)
    |> Node.get_in(rest)
  end

  def get_in(enum, []), do: enum

  def update_in(tuple, [index], fun) when is_tuple(tuple) and is_integer(index) do
    put_elem(tuple, index, fun.(elem(tuple, index)))
  end

  def update_in(list, [index], fun) when is_list(list) and is_integer(index) do
    List.update_at(list, index, fun)
  end

  def update_in(tuple, [index | rest], fun) when is_tuple(tuple) and is_integer(index) do
    new_child =
      tuple
      |> elem(index)
      |> Node.update_in(rest, fun)

    put_elem(tuple, index, new_child)
  end

  def update_in(list, [index | rest], fun) when is_list(list) and is_integer(index) do
    List.update_at(list, index, &Node.update_in(&1, rest, fun))
  end

  def put_in(list_or_tuple, path, value) do
    Node.update_in(list_or_tuple, path, fn _ -> value end)
  end
end
