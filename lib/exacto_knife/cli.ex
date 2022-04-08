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

      {_, [name, path]} ->
        update_file(path, refactor(name))
    end
  end

  defp parse_args(args) do
    cmd_opts =
      OptionParser.parse(args,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case cmd_opts do
      {[help: true], _, _} -> :help
      {opts, [_refactoring, _path] = args, []} -> {opts, args}
      _ -> :help
    end
  end

  defp formatter_opts_for(file: file) do
    Format.formatter_for_file(file) |> elem(1)
  end

  defp update_file(path, fun) do
    original_content = File.read!(path)

    new_content =
      original_content
      |> Sourceror.parse_string!()
      |> fun.()
      |> Sourceror.to_string(formatter_opts_for(file: path))

    new_content = "#{new_content}\n"

    if new_content != original_content do
      IO.puts("Saving changes to #{path}.")
      File.write!(path, new_content)
    else
      IO.puts("No changes made to #{path}.")
    end
  end

  defp refactor(name) do
    fn quoted -> apply(Refactorings, String.to_atom(name), [quoted]) end
  end
end
