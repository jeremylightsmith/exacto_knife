defmodule ExactoKnife.Refactorings.OptimizeAliases do
  @moduledoc """
  Refactorings working with aliases
  """

  alias ExactoKnife.Refactorings.Node
  alias ExactoKnife.Refactorings.ZipperExtensions, as: Ze
  alias Sourceror.Zipper, as: Z

  def sort_aliases({{:alias, _, _} = node, _} = zipper) do
    previous = zipper |> Z.left() |> Ze.safe_node()

    zipper = if has_qualified_tuple?(node), do: sort_alias_segments(zipper), else: zipper

    if previous && alias?(previous) && node_to_string(node) < node_to_string(previous) do
      swap_with_previous_node(zipper)
    else
      zipper
    end
  end

  def sort_aliases(zipper), do: zipper

  # assumes that the aliases have already been sorted
  def consolidate_aliases({{:alias, _, _} = node, _} = zipper) do
    previous = zipper |> Z.left() |> Ze.safe_node()

    cond do
      # we should expand an alias with only one segment, e.g. alias Foo.{Bar}
      has_qualified_tuple?(node) && length(get_alias_short_names_from(node)) == 1 ->
        expand_aliases(zipper)

      # no previous alias
      !previous || !alias?(previous) ->
        zipper

      # we can't (shouldn't?) handle complex aliases (that have as:)
      complex_alias?(node) || complex_alias?(previous) ->
        zipper

      # this and previous alias share a root
      node_to_alias_parent(node) == node_to_alias_parent(previous) ->
        combine_aliases(zipper, node, previous)

      true ->
        zipper
    end
  end

  def consolidate_aliases(zipper), do: zipper

  defp combine_aliases(zipper, node, previous) do
    cond do
      has_qualified_tuple?(node) ->
        names = get_alias_short_names_from(previous)

        zipper
        |> add_to_qualified_tuple(names)
        |> Z.left()
        |> Z.remove()

      has_qualified_tuple?(previous) ->
        names = get_alias_short_names_from(node)

        zipper
        |> Z.left()
        |> add_to_qualified_tuple(names)
        |> Z.right()
        |> Z.remove()

      true ->
        names = get_alias_short_names_from(previous)

        zipper
        |> change_alias_to_qualified_tuple()
        |> add_to_qualified_tuple(names)
        |> Z.left()
        |> Z.remove()
    end
  end

  # borrowed from sourceror example :)
  def expand_aliases(
        {{:alias, alias_meta, [{{:., _, [left, :{}]}, call_meta, right}]}, _metadata} = zipper
      ) do
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

  def expand_aliases(zipper), do: zipper

  def get_alias_short_names_from({:alias, _, [{{:., _, _}, _, children}]}) do
    children
    |> Enum.map(fn {:__aliases__, _, [name]} -> name end)
  end

  def get_alias_short_names_from({:alias, _, [{:__aliases__, _, names}]}) do
    [List.last(names)]
  end

  def sort_alias_segments(zipper) do
    segments = zipper |> Z.node() |> get_alias_short_names_from()

    if segments != Enum.sort(segments) do
      # this happens to do it
      add_to_qualified_tuple(zipper, [])
    else
      zipper
    end
  end

  def add_to_qualified_tuple({{:alias, _, _} = node, _} = zipper, names) do
    new_node =
      node
      |> Node.update_in([2, 0, 2], fn children ->
        new_aliases = Enum.map(names, &{:__aliases__, [], [&1]})

        (children ++ new_aliases)
        |> Enum.sort_by(&elem(&1, 2))
      end)

    zipper
    |> Z.replace(new_node)
  end

  def change_alias_to_qualified_tuple(
        {{:alias, _, [{:__aliases__, aliases_meta, names} | _]} = node, _} = zipper
      ) do
    {last, root} = names |> List.pop_at(-1)

    new_node =
      node
      |> Node.put_in([2, 0], {
        {:., [], [{:__aliases__, aliases_meta, root}, :{}]},
        [],
        [{:__aliases__, [], [last]}]
      })

    zipper
    |> Z.replace(new_node)
  end

  defp swap_with_previous_node(zipper) do
    {previous, _} = zipper |> Z.left()

    zipper
    |> Z.insert_right(previous)
    |> Z.left()
    |> Z.remove()
  end

  defp alias?({:alias, _, _}), do: true
  defp alias?(_), do: false

  defp complex_alias?({:alias, _, [_, _ | _]}), do: true
  defp complex_alias?({:alias, _, _}), do: false

  defp has_qualified_tuple?({:alias, _, [{{:., _, _}, _, _}]}), do: true
  defp has_qualified_tuple?({:alias, _, _}), do: false

  def debug({node, _} = zipper, label: label) do
    # credo:disable-for-next-line
    IO.inspect(node_to_string(node), label: label)
    zipper
  end

  defp node_to_string({:alias, _, children}) do
    "alias #{node_to_string(children)}"
  end

  defp node_to_string(children) when is_list(children) do
    children
    |> Enum.map_join(".", &node_to_string/1)
  end

  defp node_to_string({:__aliases__, _, children}) do
    children
    |> Enum.map_join(".", &Atom.to_string/1)
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

  # will return all but the last item of the alias
  # e.g.
  #   alias Foo.Bar.Baz -> [:Foo, :Bar]
  #   alias Foo.Bar.{Baz,Boop} -> [:Foo, :Bar]
  def node_to_alias_parent({:alias, _, [{{:., _, [{:__aliases__, _, names}, _]}, _, _} | _]}) do
    names
  end

  def node_to_alias_parent({:alias, _, [{:__aliases__, _, names} | _]}) do
    Enum.drop(names, -1)
  end

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
