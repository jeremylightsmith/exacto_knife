defmodule Mix.Tasks.Refactor do
  @moduledoc "The refactor mix task: `mix help refactor`"
  use Mix.Task
  alias ExFactor.CLI

  @shortdoc "Perform refactorings on your code"
  def run(args) do
    CLI.main(args)
  end
end
