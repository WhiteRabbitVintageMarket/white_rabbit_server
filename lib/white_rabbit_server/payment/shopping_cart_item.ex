defmodule WhiteRabbitServer.Payment.ShoppingCartItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :sku, :string
    field :quantity, :integer, default: 1
  end

  @doc false
  def create_shopping_cart_item(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_changes
  end

  @doc false
  def changeset(shopping_cart_item, attrs) do
    shopping_cart_item
    |> cast(attrs, [
      :sku,
      :quantity
    ])
    |> validate_required([:sku])
  end
end
