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
      sku: product.sku,
      name: product.name,
      description: format_optional_attr(product.description),
      size: format_optional_attr(product.size),
      amount: money_to_string(product.amount),
      shipping_amount: money_to_string(product.shipping_amount),
      image_url: product.image_url,
      is_sold: product.is_sold
    }
  end

  defp format_optional_attr(nil), do: ""
  defp format_optional_attr(attr), do: attr

  defp money_to_string(nil), do: ""
  defp money_to_string(amount), do: Money.to_string(amount, symbol: false)
end
