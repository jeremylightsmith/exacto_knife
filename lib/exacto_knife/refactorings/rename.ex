defmodule ExactoKnife.Refactorings.Rename do
  @moduledoc """
  Rename refactorings
  """

  alias ExactoKnife.Refactorings.ZipperExtensions, as: Ze
  alias Sourceror.Zipper, as: Z

  def rename(zipper, cursor, new_name) do
    case Ze.find_variable_at_position(zipper, cursor) do
      nil ->
        IO.puts("Couldn't find a variable at #{inspect(cursor)}.")
        zipper

      {{current_name, _, _}, _} = pos_zipper ->
        scope = Ze.find_up(pos_zipper, &lexical_scope?/1) || zipper
        rename_instances(scope, current_name, String.to_atom(new_name))
    end
  end

  def rename_instances(zipper, current_name, new_name) do
    zipper
    |> Z.traverse(fn
      {{marker, _, _} = node, _} = z ->
        cond do
          marker == current_name ->
            Z.replace(z, put_elem(node, 0, new_name))

          # skip renaming inside of other scopes
          Ze.safe_node(zipper) != Ze.safe_node(z) && lexical_scope?(node) ->
            Z.skip(z)

          true ->
            z
        end

      z ->
        z
    end)
  end

  def lexical_scope?({:def, _, _}), do: true
  def lexical_scope?({:defp, _, _}), do: true
  def lexical_scope?({:test, _, _}), do: true
  def lexical_scope?(_), do: false
end
