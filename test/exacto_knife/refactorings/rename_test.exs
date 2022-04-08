defmodule ExactoKnife.Refactorings.RenameTest do
  @moduledoc false
  use ExactoKnife.TestCase, async: true

  import ExUnit.CaptureIO

  describe "rename/1" do
    test "should do nothing if it can't find the variable" do
      source = ~S"""
      bar = 20
      bar = bar * 2
      """

      assert {source, "Couldn't find a variable at {1, 7}.\n"} ==
               with_io(fn ->
                 refactor(:rename, source, [{1, 7}, "foo"])
               end)
    end

    test "should change all instances of a variable at top scope" do
      source = ~S"""
      bar = 20
      baz = 30

      if baz > bar do
        bar = bar * baz
      end

      IO.puts(inspect(bar))
      """

      expected = ~S"""
      bar = 20
      foo = 30

      if foo > bar do
        bar = bar * foo
      end

      IO.puts(inspect(bar))
      """

      assert expected == refactor(:rename, source, [{2, 1}, "foo"])
      assert expected == refactor(:rename, source, [{2, 4}, "foo"])
      assert expected == refactor(:rename, source, [{5, 18}, "foo"])

      assert ~S"""
             food = 20
             baz = 30

             if baz > food do
               food = food * baz
             end

             IO.puts(inspect(food))
             """ == refactor(:rename, source, [{8, 17}, "food"])
    end

    @tag :skip
    test "should only change instances in a function" do
      source = ~S"""
      bar = 3

      def foo() do
        bar = 2
        baz = bar * 2
      end

      defp food() do
        bar = 2
        baz = bar * 2
      end
      """

      assert ~S"""
             bomb = 3

             def foo() do
               bar = 2
               baz = bar * 2
             end

             defp food() do
               bar = 2
               baz = bar * 2
             end
             """ == refactor(:rename, source, [{1, 2}, "bomb"])

      assert ~S"""
             bar = 3

             def foo() do
               bomb = 2
               baz = bomb * 2
             end

             defp food() do
               bar = 2
               baz = bar * 2
             end
             """ == refactor(:rename, source, [{5, 10}, "bomb"])

      assert ~S"""
             bar = 3

             def foo() do
               bar = 2
               baz = bar * 2
             end

             defp food() do
               bomb = 2
               baz = bomb * 2
             end
             """ == refactor(:rename, source, [{9, 3}, "bomb"])
    end
  end
end
