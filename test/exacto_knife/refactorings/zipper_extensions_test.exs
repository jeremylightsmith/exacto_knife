defmodule ExactoKnife.Refactorings.ZipperExtensionsTest do
  @moduledoc false
  use ExactoKnife.TestCase, async: true

  alias ExactoKnife.Refactorings.ZipperExtensions, as: Ze
  alias Sourceror.Zipper, as: Z

  describe "#find_back/2" do
    test "finds a thing" do
      z = Z.zip([1, [2, [3, 4]], 5, 6])

      at_5 = z |> Z.find(&(&1 == 5))

      assert nil == z |> Z.find(&(&1 == 10))
      assert {3, %{l: nil, r: [4]}} = z |> Z.find(&(&1 == 3))
      assert {5, %{r: [6]}} = at_5
      assert {2, %{r: [[3, 4]]}} = at_5 |> Ze.find_back(&(&1 == 2))
      assert nil == at_5 |> Ze.find_back(&(&1 == 20))
    end
  end

  describe "#find_variable_at_position/2" do
    test "find var" do
      z =
        ~S"""
        def foo() do
          bar = 2
          baz = bar * 2
        end
        """
        |> Sourceror.parse_string!()
        |> Z.zip()

      assert {:bar, _, nil} = Ze.find_variable_at_position(z, {2, 3}) |> Z.node()
      assert {:bar, _, nil} = Ze.find_variable_at_position(z, {2, 4}) |> Z.node()
      assert {:bar, _, nil} = Ze.find_variable_at_position(z, {2, 5}) |> Z.node()
      assert {:bar, _, nil} = Ze.find_variable_at_position(z, {2, 6}) |> Z.node()
      assert nil == Ze.find_variable_at_position(z, {2, 2})
      assert nil == Ze.find_variable_at_position(z, {2, 7})
      assert nil == Ze.find_variable_at_position(z, {2, 8})
      assert nil == Ze.find_variable_at_position(z, {2, 9})
      assert nil == Ze.find_variable_at_position(z, {2, 10})
      assert {:baz, _, nil} = Ze.find_variable_at_position(z, {3, 3}) |> Z.node()
    end
  end

  describe "#safe_node/1" do
    test "should return the node or nil" do
      assert 1 == Ze.safe_node({1, 2})
      assert 55 == Ze.safe_node({55, 2})
      assert nil == Ze.safe_node(nil)
    end
  end
end
