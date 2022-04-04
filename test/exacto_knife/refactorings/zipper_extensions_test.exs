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
end
