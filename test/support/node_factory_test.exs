defmodule NodeFactoryTest do
  use ExFactor.TestCase, async: true

  describe "build/n" do
    test "should build aliases" do
      assert {:alias, [], [{:__aliases__, [], [:Foo, :Bar]}]} == build(:alias, "Foo.Bar")
      assert {:alias, _, [{:__aliases__, _, [:Foo, :Bar]}]} = build("alias Foo.Bar")
    end

    test "should build aliases w/ qualified tuples" do
      assert {:alias, _,
              [
                {{:., _, [{:__aliases__, _, [:Foo, :Bar]}, :{}]}, _,
                 [
                   {:__aliases__, _, [:Baz]},
                   {:__aliases__, _, [:Bob]}
                 ]}
              ]} = build("alias Foo.Bar.{Baz,Bob}")
    end
  end
end
