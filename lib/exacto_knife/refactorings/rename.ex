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

      {{current_name, _, _}, _} ->
        rename_instances(zipper, current_name, String.to_atom(new_name))
    end
  end

  def rename_instances(zipper, current_name, new_name) do
    zipper
    |> Z.traverse(fn
      {{marker, _, _} = node, _} = z when is_atom(marker) ->
        if marker == current_name do
          Z.replace(z, put_elem(node, 0, new_name))
        else
          z
        end

      z ->
        z
    end)
  end
end
