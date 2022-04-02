defmodule ExactoKnife.Refactorings.OptimizeAliases do
  alias Sourceror.Zipper, as: Z

  def optimize_aliases(quoted) do
    Z.zip(quoted)
    |> Z.traverse(&sort_aliases/1)
    |> Z.root()
  end

  defp sort_aliases({{:alias, _, _} = node, _} = zipper) do
    case zipper |> Z.left() do
      {previous, _} ->
        if alias?(previous) && node_to_string(node) < node_to_string(previous) do
          swap_with_previous_node(zipper)
        else
          zipper
        end
      nil -> zipper
    end
  end

  defp sort_aliases(zipper), do: zipper

  defp swap_with_previous_node(zipper) do
    {previous, _} = zipper |> Z.left()

    zipper
    |> Z.insert_right(previous)
    |> Z.left()
    |> Z.remove()
  end

  defp alias?({:alias, _, _}), do: true
  defp alias?(_), do: false

  defp debug({node, _} = zipper, label: label) do
    IO.inspect(node_to_string(node), label: label)
    zipper
  end

  defp node_to_string({:alias, _, children}) do
    "alias #{node_to_string(children)}"
  end

  defp node_to_string(children) when is_list(children) do
    children
    |> Enum.map(&node_to_string/1)
    |> Enum.join(".")
  end

  defp node_to_string({:__aliases__, _, children}) do
    children
    |> Enum.map(&Atom.to_string/1)
    |> Enum.join(".")
  end

  defp node_to_string({{:., _, root}, _, children}) do
    "#{node_to_string(root)}{#{node_to_string(children)}}"
  end

  defp node_to_string(:{}), do: ""

  defp node_to_string({marker, _, _children}) do
    "#{marker}"
  end

  defp node_to_string(_) do
    "unknown"
  end

  defp expand_alias(
         {{:alias, alias_meta, [{{:., _, [left, :{}]}, call_meta, right}]}, _metadata} = zipper
       ) do
    IO.puts("===========================================")
    IO.puts("expand alias")
    # IO.puts("expand alias(#{inspect(zipper)})")
    IO.inspect(left, label: "left", pretty: true, limit: :infinity)
    IO.inspect(call_meta, label: "call_meta", pretty: true, limit: :infinity)
    IO.inspect(right, label: "right", pretty: true, limit: :infinity)
    {_, _, base_segments} = left

    leading_comments = alias_meta[:leading_comments] || []
    trailing_comments = call_meta[:trailing_comments] || []

    right
    |> Enum.map(&segments_to_alias(base_segments, &1))
    |> put_leading_comments(leading_comments)
    |> put_trailing_comments(trailing_comments)
    |> Enum.reverse()
    |> Enum.reduce(zipper, &Z.insert_right(&2, &1))
    |> Z.remove()
  end

  defp expand_alias(zipper), do: zipper

  defp segments_to_alias(base_segments, {_, meta, segments}) do
    {:alias, meta, [{:__aliases__, [], base_segments ++ segments}]}
  end

  defp put_leading_comments([first | rest], comments) do
    [Sourceror.prepend_comments(first, comments) | rest]
  end

  defp put_trailing_comments(list, comments) do
    case List.pop_at(list, -1) do
      {nil, list} ->
        list

      {last, list} ->
        last =
          {:__block__,
           [
             trailing_comments: comments,
             end_of_expression: [newlines: 2]
           ], [last]}

        list ++ [last]
    end
  end
end
