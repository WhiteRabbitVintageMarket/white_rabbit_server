defmodule WhiteRabbitServerWeb.ProductJSON do
  alias WhiteRabbitServer.Catalog.Product

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  defp data(%Product{} = product) do
    %{
      id: product.id,
      sku: product.sku,
      name: product.name,
      description: product.description,
      size: product.size,
      amount: Money.to_string(product.amount, symbol: false),
      shipping_amount: Money.to_string(product.shipping_amount, symbol: false),
      image_url: product.image_url,
      is_sold: product.is_sold
    }
  end
end
