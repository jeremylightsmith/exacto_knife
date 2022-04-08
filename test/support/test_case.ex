defmodule ExactoKnife.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import ExactoKnife.NodeFactory
      import ExactoKnife.TestCase
    end
  end

  def refactor(name, source, params \\ []) do
    quoted = Sourceror.parse_string!(source)

    new_string =
      apply(ExactoKnife.Refactorings, name, [quoted | params])
      |> Sourceror.to_string()

    "#{new_string}\n"
  end
end
