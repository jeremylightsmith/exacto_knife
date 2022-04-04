defmodule ExactoKnife.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import ExactoKnife.NodeFactory
    end
  end
end
