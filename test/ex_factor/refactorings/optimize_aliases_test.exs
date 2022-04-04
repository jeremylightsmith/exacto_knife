defmodule ExFactor.Refactorings.OptimizeAliasesTest do
  use ExFactor.TestCase, async: true

  alias ExFactor.Refactorings
  alias ExFactor.Refactorings.OptimizeAliases
  alias Sourceror.Zipper, as: Z

  def refactor(name, source) do
    quoted = Sourceror.parse_string!(source)

    apply(Refactorings, name, [quoted])
    |> Sourceror.to_string()
  end

  describe "sort_aliases/1" do
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

      assert String.trim(expected) == refactor(:sort_aliases, input)
    end

    test "should sort complex aliases" do
      input = ~S"""
      alias Charlie, as: C
      alias Bravo
      alias Alpha, as: A
      """

      expected = ~S"""
      alias Alpha, as: A
      alias Bravo
      alias Charlie, as: C
      """

      assert String.trim(expected) == refactor(:sort_aliases, input)
    end

    test "should sort alias tuples" do
      input = ~S"""
      alias Charlie.{
        Foo,
        Bar,
        Baz,
        Back
      }
      alias Bravo
      """

      expected = ~S"""
      alias Bravo

      alias Charlie.{
        Back,
        Bar,
        Baz,
        Foo
      }
      """

      assert String.trim(expected) == refactor(:sort_aliases, input)
    end
  end

  describe "consolidate_aliases/1" do
    test "consolidate" do
      input = ~S"""
      alias Bob
      alias George
      alias Foo.Goo.Sam
      alias Foo.Moon
      alias Foo.Goo.Dad
      """

      expected = ~S"""
      alias Bob
      alias Foo.Goo.{Dad, Sam}
      alias Foo.Moon
      alias George
      """

      assert String.trim(expected) == refactor(:consolidate_aliases, input)
    end

    test "add to qualified tuple" do
      input = ~S"""
      alias Foo.Goo.{Zee, Claire}
      alias Foo.Goo.Sam
      alias Foo.Moon
      alias Foo.Goo.Dad
      """

      expected = ~S"""
      alias Foo.Goo.{Claire, Dad, Sam, Zee}
      alias Foo.Moon
      """

      assert String.trim(expected) == refactor(:consolidate_aliases, input)
    end

    test "should expand aliases when only one" do
      input = ~S"""
      defmodule Foo do
        alias Foo.Goo.{Gab}
      end
      """

      expected = ~S"""
      defmodule Foo do
        alias Foo.Goo.Gab
      end
      """

      assert String.trim(expected) == refactor(:consolidate_aliases, input)
    end
  end

  describe "expand_aliases/1" do
    test "complex" do
      input = ~S"""
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

      expected = ~S"""
      defmodule Sample do
        # Some aliases
        alias Foo.A
        alias Foo.B
        alias Foo.C
        alias Foo.D
        alias Foo.E
        alias Foo.F

        # Hello!
        alias Bar.G
        alias Bar.H
        alias Bar.I
        # Inner comment!
        # Inner comment 2!
        # Inner comment 3!
        alias Bar.J
        # Comment for K!
        # Comment for K 2!
        alias Bar.K

        # Inner last comment!
        # Inner last comment 2!

        # Not an inner comment

        def foo() do
          # Some scoped alias
          alias Baz.A
          alias Baz.B
          alias Baz.C

          # Just return :ok
          :ok

          # At the end
        end

        # Comment for :hello
        :hello
      end

      # End of file!
      """

      assert String.trim(expected) == refactor(:expand_aliases, input)
    end
  end

  describe "#get_alias_short_names_from/1" do
    test "get from single alias" do
      assert [:Bar] == OptimizeAliases.get_alias_short_names_from(build("alias Foo.Bar"))
      assert [:Boo] == OptimizeAliases.get_alias_short_names_from(build("alias Foo.Bar.Boo"))
      assert [:Foo] == OptimizeAliases.get_alias_short_names_from(build("alias Foo"))
    end

    test "get from tuple" do
      assert [:Baz, :Bam] ==
               OptimizeAliases.get_alias_short_names_from(build("alias Foo.Bar.{Baz,Bam}"))
    end
  end

  describe "#node_to_alias_parent/1" do
    test "from single alias" do
      assert [:Foo] == OptimizeAliases.node_to_alias_parent(build("alias Foo.Bar"))
      assert [:Foo, :Bar] == OptimizeAliases.node_to_alias_parent(build("alias Foo.Bar.Boo"))
      assert [] == OptimizeAliases.node_to_alias_parent(build("alias Foo"))
    end

    test "from tuple" do
      assert [:Foo, :Bar] ==
               OptimizeAliases.node_to_alias_parent(build("alias Foo.Bar.{Baz,Bam}"))
    end
  end

  describe "#add_to_qualified_tuple/2" do
    test "should add names to alias tuple" do
      z = build("alias Foo.Bar.{Bam,Astro,Cheese}") |> Z.zip()

      assert {:alias, _,
              [
                {
                  {:., _, [{:__aliases__, _, [:Foo, :Bar]}, :{}]},
                  _,
                  [
                    {:__aliases__, _, [:Alpha]},
                    {:__aliases__, _, [:Astro]},
                    {:__aliases__, _, [:Bam]},
                    {:__aliases__, _, [:Cheese]},
                    {:__aliases__, _, [:Foo]},
                    {:__aliases__, _, [:Zoom]}
                  ]
                }
              ]} = OptimizeAliases.add_to_qualified_tuple(z, [:Foo, :Alpha, :Zoom]) |> Z.node()
    end
  end

  describe "#change_alias_to_qualified_tuple/2" do
    test "should add names to alias tuple" do
      z = build("alias Foo.Bar.Bam") |> Z.zip()

      assert {:alias, _,
              [
                {
                  {:., _, [{:__aliases__, _, [:Foo, :Bar]}, :{}]},
                  _,
                  [
                    {:__aliases__, _, [:Bam]}
                  ]
                }
              ]} = OptimizeAliases.change_alias_to_qualified_tuple(z) |> Z.node()
    end
  end
end
