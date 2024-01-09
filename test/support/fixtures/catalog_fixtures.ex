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
        description: "some description",
        is_sold: true,
        name: "some name",
        price: "some price",
        size: "some size",
        sku: "some sku",
        url: "some url"
      })
      |> WhiteRabbitServer.Catalog.create_product()

    product
  end
end
