defmodule ExFactor.CLI do
  alias ExFactor.Refactorings

  def main(args \\ []) do
    case parse_args(args) do
      :help ->
        IO.puts("""
        ExFactor Usage:
          ex_factor [REFACTOR] [FILE]

          e.g. ex_factor consolidate_aliases lib/project/stuff.ex
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

  defp update_file(path, fun) do
    new_content =
      File.read!(path)
      |> Sourceror.parse_string!()
      |> fun.()
      |> Sourceror.to_string()

    File.write!(path, new_content)
  end

  defp refactor(name) do
    fn quoted -> apply(Refactorings, String.to_atom(name), [quoted]) end
  end
end
