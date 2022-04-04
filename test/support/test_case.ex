defmodule ExactoKnife.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import ExactoKnife.NodeFactory
    end
  end
end
