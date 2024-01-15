defmodule WhiteRabbitServer.Payment.ShoppingCart do
  alias WhiteRabbitServer.Catalog
  alias WhiteRabbitServer.Catalog.Product
  alias WhiteRabbitServer.Payment.ShoppingCartItem

  def get_products_from_shopping_cart(shopping_cart)
      when is_list(shopping_cart) and length(shopping_cart) > 0 do
    case get_shopping_cart_items(shopping_cart) do
      {:ok, shopping_cart_items} ->
        get_products(shopping_cart_items)

      {:error, _errors} ->
        {:error, "Invalid shopping_cart items"}
    end
  end

  def get_products_from_shopping_cart(_shopping_cart) do
    {:error, "Expected shopping_cart to be a list with at least 1 item"}
  end

  defp get_shopping_cart_items(shopping_cart) do
    Enum.reduce_while(shopping_cart, {:ok, []}, fn shopping_cart_item, {:ok, items} ->
      %Ecto.Changeset{valid?: valid?, errors: errors} =
        ShoppingCartItem.changeset(%ShoppingCartItem{}, shopping_cart_item)

      case valid? do
        true ->
          new_shopping_cart_item = ShoppingCartItem.create_shopping_cart_item(shopping_cart_item)
          {:cont, {:ok, items ++ [new_shopping_cart_item]}}

        false ->
          {:halt, {:error, errors}}
      end
    end)
  end

  defp get_products(shopping_cart_items) do
    Enum.reduce_while(shopping_cart_items, {:ok, []}, fn item, acc ->
      %ShoppingCartItem{sku: sku, quantity: quantity} = item
      {:ok, products} = acc

      case Catalog.get_product_by_sku(sku) do
        %Product{} = product ->
          if product.is_sold do
            {:halt, {:error, "Product is sold out for sku #{sku}"}}
          else
            product_with_quantity = Map.put(product, :quantity, quantity)
            {:cont, {:ok, products ++ [product_with_quantity]}}
          end

        nil ->
          {:halt, {:error, "Failed to get product for sku #{sku}"}}
      end
    end)
  end
end
