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

  defp data(%Product{
         sku: sku,
         name: name,
         description: description,
         size: size,
         amount: amount,
         shipping_amount: shipping_amount,
         image_url: image_url,
         quantity: quantity
       }) do
    %{
      sku: sku,
      name: name,
      description: format_optional_attr(description),
      size: format_optional_attr(size),
      amount: money_to_string(amount),
      shipping_amount: money_to_string(shipping_amount),
      image_url: image_url,
      quantity: quantity
    }
  end

  defp format_optional_attr(nil), do: ""
  defp format_optional_attr(attr), do: attr

  defp money_to_string(nil), do: ""
  defp money_to_string(amount), do: Money.to_string(amount, symbol: false)
end
