defmodule WhiteRabbitServer.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :size, :string
    field :description, :string
    field :url, :string
    field :sku, :string
    field :amount, Money.Ecto.Amount.Type
    field :is_sold, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :name, :description, :size, :amount, :url, :is_sold])
    |> validate_required([:sku, :name, :description, :size, :amount, :url, :is_sold])
  end
end
