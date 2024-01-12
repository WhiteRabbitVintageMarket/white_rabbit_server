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
    :is_sold,
    :posted_at,
    :sold_at
  ]

  @required_attrs [
    :sku,
    :name,
    :image_url,
    :is_sold
  ]

  schema "products" do
    field :name, :string
    field :size, :string
    field :description, :string
    field :image_url, :string
    field :sku, :string
    field :amount, Money.Ecto.Amount.Type
    field :shipping_amount, Money.Ecto.Amount.Type
    field :is_sold, :boolean, default: false
    field :posted_at, :utc_datetime
    field :sold_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> unique_constraint(:sku)
  end
end
