defmodule WhiteRabbitServer.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :sku,
    :name,
    :description,
    :size,
    :amount,
    :shipping_amount,
    :image_url,
    :quantity,
    :posted_at
  ]

  @required_attrs [
    :sku,
    :name,
    :image_url,
    :quantity
  ]

  schema "products" do
    field :name, :string
    field :size, :string
    field :description, :string
    field :image_url, :string
    field :sku, :string
    field :amount, Money.Ecto.Amount.Type
    field :shipping_amount, Money.Ecto.Amount.Type
    field :quantity, :integer
    field :posted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:sku)
    |> validate_inclusion(:quantity, 0..10)
  end
end
