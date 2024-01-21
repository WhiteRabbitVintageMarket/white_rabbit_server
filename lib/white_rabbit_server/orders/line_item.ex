defmodule WhiteRabbitServer.Orders.LineItem do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :unit_amount,
    :quantity,
    :order_id,
    :product_id
  ]

  schema "order_line_items" do
    field :unit_amount, Money.Ecto.Amount.Type
    field :quantity, :integer

    belongs_to :order, WhiteRabbitServer.Orders.Order
    belongs_to :product, WhiteRabbitServer.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(line_item, attrs) do
    line_item
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> validate_inclusion(:quantity, 1..10)
  end
end
