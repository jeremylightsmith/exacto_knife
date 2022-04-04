defmodule ExactoKnife.NodeFactory do
  def build(:__aliases__, names) do
    {:__aliases__, [], names}
  end

  def build(:alias, name) when is_binary(name) do
    {:alias, [],
     [
       build(
         :__aliases__,
         name |> String.split(".") |> Enum.map(&String.to_existing_atom/1)
       )
     ]}
  end

  def build(source) when is_binary(source) do
    Sourceror.parse_string!(source)
  end
end
