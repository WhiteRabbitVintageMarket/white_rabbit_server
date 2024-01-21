defmodule WhiteRabbitServer.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WhiteRabbitServer.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        sku: Ecto.UUID.generate(),
        description: "some description",
        quantity: 1,
        name: "some name",
        amount: Money.new(100, :USD),
        shipping_amount: Money.new(50, :USD),
        size: "some size",
        image_url: "some url"
      })
      |> WhiteRabbitServer.Catalog.create_product()

    product
  end
end
