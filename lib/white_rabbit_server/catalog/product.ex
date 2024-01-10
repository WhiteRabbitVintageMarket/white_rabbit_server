defmodule WhiteRabbitServer.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :size, :string
    field :description, :string
    field :image_url, :string
    field :sku, :string
    field :amount, Money.Ecto.Amount.Type
    field :shipping_amount, Money.Ecto.Amount.Type
    field :is_sold, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :sku,
      :name,
      :description,
      :size,
      :amount,
      :shipping_amount,
      :image_url,
      :is_sold
    ])
    |> validate_required([
      :sku,
      :name,
      :description,
      :size,
      :amount,
      :shipping_amount,
      :image_url,
      :is_sold
    ])
    |> unique_constraint(:sku)
  end
end
