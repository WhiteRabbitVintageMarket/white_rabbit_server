defmodule WhiteRabbitServer.ShoppingCart.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @attrs [
    :sku,
    :quantity
  ]

  embedded_schema do
    field :sku, :string
    field :quantity, :integer
    embeds_one :product, WhiteRabbitServer.Catalog.Product
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> cast_embed(:product, required: true)
    |> validate_inclusion(:quantity, 1..10)
  end

  def create_item(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_changes
  end
end
