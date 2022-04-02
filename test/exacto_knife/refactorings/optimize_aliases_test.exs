defmodule OptimizeAliasesTest do
  use ExUnit.Case, async: true

  alias ExactoKnife.Refactorings.OptimizeAliases

  def refactor(source) do
    source
    |> Sourceror.parse_string!()
    |> OptimizeAliases.optimize_aliases()
    |> Sourceror.to_string()
  end

  test "should sort aliases" do
    input = ~S"""
    alias Echo
    # alpha rulez
    alias Alpha
    # bravo is the beest
    alias Bravo.{Charlie, Delta}
    alias Bravo
    """

    expected = ~S"""
    # alpha rulez
    alias Alpha
    alias Bravo
    # bravo is the beest
    alias Bravo.{Charlie, Delta}
    alias Echo
    """

    assert String.trim(expected) == refactor(input)
  end

  test "consolidate aliases" do
    input = ~S"""
    alias Foo.Goo.Sam
    alias Foo.Moon
    alias Foo.Goo.Dad
    """

    expected = ~S"""
    alias Foo.Goo.{Dad, Sam}
    alias Foo.Moon
    """

    assert expected == refactor(input)
  end

  # {
  #   {:., _, [{:__aliases__, _, [:Foo, :Goo]}, :{}]},
  #   _,
  #   [
  #     {:__aliases__, _, [:Bar]},
  #     {:__aliases__, _, [:Lucky]}
  #   ]
  # }

  test "it works" do
    input = ~S"""
    alias Foo.Bar.Baz
    alias Foo.Lucky.Guy
    alias Foo.Bar
    alias Foo.{ Sam, Shady }
    alias Foo.Bar.Shoe
    alias Foo.Lucky
    alias Foo.Bar.Back
    """

    expected = ~S"""
    alias Foo.{
      Bar,
      Lucky
    }
    alias Foo.Bar.{
      Baz,
      Shoe
    }
    """

    # assert expected == refactor(input)
    assert input == refactor(expected)
  end

  test "complex" do
    source = ~S"""
    defmodule Sample do
      # Some aliases
      alias Foo.{A, B, C, D, E, F}

      # Hello!
      alias Bar.{G, H, I,

        # Inner comment!
        # Inner comment 2!
        # Inner comment 3!
        J,

        # Comment for K!
        K # Comment for K 2!

        # Inner last comment!
        # Inner last comment 2!
      } # Not an inner comment

      def foo() do
        # Some scoped alias
        alias Baz.{A, B, C}

        # Just return :ok
        :ok

        # At the end
      end

      # Comment for :hello
      :hello
    end
    # End of file!
    """

  end
end
