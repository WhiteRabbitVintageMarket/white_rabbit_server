defmodule WhiteRabbitServer.Payment.ShoppingCartItem do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @attrs [
    :sku,
    :quantity,
    :name,
    :description,
    :amount
  ]

  @required_attrs [
    :sku,
    :quantity
  ]

  embedded_schema do
    field :sku, :string
    field :quantity, :integer
    field :name, :string
    field :description, :string
    field :amount, Money.Ecto.Amount.Type
  end

  @doc false
  def changeset(shopping_cart_item, attrs) do
    shopping_cart_item
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> validate_length(:name, max: 127)
    |> validate_length(:description, max: 127)
    |> validate_inclusion(:quantity, 1..10)
  end
end
