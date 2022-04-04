defmodule ExFactor.Refactorings.NodeTest do
  use ExFactor.TestCase, async: true

  alias ExFactor.Refactorings.Node

  describe "#get_in/2" do
    test "works" do
      tuple = {1, {2, {3, 4}}, [5, {6, 7}]}

      assert 1 == Node.get_in(tuple, [0])
      assert {3,4} == Node.get_in(tuple, [1, 1])
      assert 3 == Node.get_in(tuple, [1, 1, 0])
      assert 5 == Node.get_in(tuple, [2, 0])
      assert 7 == Node.get_in(tuple, [2, 1, 1])
    end
  end

  describe "#put_in/3" do
    test "put value in random place" do
      tuple = {{1, {7, 8}}, 2, {3, 4, {5, 6}}}

      assert {{1, {7, 8}}, 2, :new} == put_elem(tuple, 2, :new)
      assert {{1, {7, 8}}, 2, :new} == Node.put_in(tuple, [2], :new)
      assert {{1, {7, 8}}, 2, {3, 4, :new}} == Node.put_in(tuple, [2, 2], :new)

      assert {{1, {7, 8}}, 2, {3, 4, {5, 20}}} ==
               Node.put_in(tuple, [2, 2, 1], 20)
    end

    test "should traverse lists too" do
      tuple = {{1, [{7, 8}, 9]}, 2, [3, 4]}

      assert {{1, [{7, 8}, 12]}, 2, [3, 4]} == Node.put_in(tuple, [0, 1, 1], 12)
      assert {{1, [{7, -1}, 9]}, 2, [3, 4]} == Node.put_in(tuple, [0, 1, 0, 1], -1)
      assert {{1, [{7, 8}, 9]}, 2, [3, 20]} == Node.put_in(tuple, [2, 1], 20)
    end
  end

  describe "#update_in/3" do
    test "update value in random place" do
      double = &(&1 * 2)
      tuple = {{1, {7, 8}}, 2}

      assert {{1, {7, 8}}, 4} == Node.update_in(tuple, [1], double)
      assert {{1, {14, 8}}, 2} == Node.update_in(tuple, [0, 1, 0], double)
    end

    test "should traverse lists too" do
      double = &(&1 * 2)
      tuple = {{1, [{7, 8}, 9]}, 2, [3, 4]}

      assert {{1, [{7, 8}, 18]}, 2, [3, 4]} == Node.update_in(tuple, [0, 1, 1], double)
      assert {{1, [{7, 16}, 9]}, 2, [3, 4]} == Node.update_in(tuple, [0, 1, 0, 1], double)
      assert {{1, [{7, 8}, 9]}, 2, [3, 8]} == Node.update_in(tuple, [2, 1], double)
    end
  end
end
