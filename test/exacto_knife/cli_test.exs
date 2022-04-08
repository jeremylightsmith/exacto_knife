defmodule ExactoKnife.CLITest do
  @moduledoc false
  use ExactoKnife.TestCase, async: true

  alias ExactoKnife.CLI

  import ExUnit.CaptureIO

  @tmpfile "/tmp/exacto.ex"

  def refactor_file(source, refactor, args \\ []) do
    File.write!(@tmpfile, source)

    capture_io(fn ->
      CLI.main([refactor, @tmpfile | args])
    end)

    File.read!(@tmpfile)
  end

  describe "#main/1" do
    test "rename" do
      source = ~S"""
      bar = 2
      bar * 2
      """

      assert ~S"""
             foo = 2
             foo * 2
             """ == refactor_file(source, "rename", ["2", "1", "foo"])
    end

    test "sort aliases" do
      source = ~S"""
      alias B
      alias C
      alias A
      """

      assert ~S"""
             alias A
             alias B
             alias C
             """ == refactor_file(source, "sort_aliases")
    end

    test "expand/consolidate aliases" do
      a = ~S"""
      alias A.Alphabet
      alias A.Pokemon

      alias B
      """

      b = ~S"""
      alias A.{Alphabet, Pokemon}

      alias B
      """

      assert a == refactor_file(b, "expand_aliases")
      assert b == refactor_file(a, "consolidate_aliases")
    end
  end
end
