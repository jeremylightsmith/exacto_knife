defmodule ExactoKnife.CLI do
  @moduledoc """
  Command line interface support
  """

  alias ExactoKnife.Refactorings
  alias Mix.Tasks.Format

  def main(args \\ []) do
    case parse_args(args) do
      :help ->
        IO.puts("""
        ExactoKnife Usage:
          exacto_knife [REFACTOR] [FILE]

          e.g. exacto_knife consolidate_aliases lib/project/stuff.ex
        """)

      {_, [name, path, args]} ->
        update_file(name, path, refactor(name, args))
    end
  end

  defp parse_args(args) do
    cmd_opts =
      OptionParser.parse(args,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case cmd_opts do
      {[help: true], _, _} ->
        :help

      {opts, ["rename", path, line, col, new_name], []} ->
        {opts, ["rename", path, [{String.to_integer(line), String.to_integer(col)}, new_name]]}

      {opts, [refactoring, path], []} ->
        {opts, [refactoring, path, []]}

      _ ->
        :help
    end
  end

  defp formatter_opts_for(file: file) do
    Format.formatter_for_file(file) |> elem(1)
  end

  defp update_file(refactor, path, fun) do
    original_content = File.read!(path)

    new_content =
      original_content
      |> Sourceror.parse_string!()
      |> fun.()
      |> Sourceror.to_string(formatter_opts_for(file: path))

    new_content = "#{new_content}\n"

    if new_content != original_content do
      IO.puts("#{refactor}: saving changes to #{path}.")
      File.write!(path, new_content)
    else
      IO.puts("#{refactor}: No changes made to #{path}.")
    end
  end

  defp refactor(name, args) do
    fn quoted -> apply(Refactorings, String.to_atom(name), [quoted | args]) end
  end
end
