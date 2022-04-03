defmodule ExFactor.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import ExFactor.NodeFactory
    end
  end
end
