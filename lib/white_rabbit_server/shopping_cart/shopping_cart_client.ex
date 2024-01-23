defmodule WhiteRabbitServer.ShoppingCart.ShoppingCartClient do
  alias WhiteRabbitServer.PayPalAPI
  alias WhiteRabbitServer.Catalog
  alias WhiteRabbitServer.Catalog.Product
  alias WhiteRabbitServer.ShoppingCart.Item
  alias WhiteRabbitServer.ShoppingCart.PayPalHelper

  def create_shopping_cart_items(shopping_cart)
      when is_list(shopping_cart) and length(shopping_cart) > 0 do
    case process_shopping_cart_items(shopping_cart) do
      {:ok, shopping_cart_items} ->
        {:ok, shopping_cart_items}

      {:error, [_head | _tail] = errors} ->
        {:error, %{message: "Invalid shopping_cart items", detail: errors}}

      {:error, error_message} ->
        {:error, %{message: error_message}}
    end
  end

  def create_shopping_cart_items(_shopping_cart) do
    {:error, %{message: "Expected shopping_cart to be a list with at least 1 item"}}
  end

  def validate_paypal_order("") do
    {:error, %{message: "Expected paypal_order_id to not be an empty string"}}
  end

  def validate_paypal_order(paypal_order_id) when is_binary(paypal_order_id) do
    case PayPalAPI.get_order(paypal_order_id) do
      {:ok, %{body: body}} ->
        body
        |> PayPalHelper.get_items_from_order()
        |> create_shopping_cart_items

      {:error, error} ->
        {:error, error}
    end
  end

  def validate_paypal_order(_paypal_order_id) do
    {:error, %{message: "Expected paypal_order_id to be a string"}}
  end

  defp process_shopping_cart_items(shopping_cart) do
    Enum.reduce_while(shopping_cart, {:ok, []}, fn item, {:ok, items} ->
      case process_shopping_cart_item(item) do
        {:ok, %Item{} = item} ->
          {:cont, {:ok, items ++ [item]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp process_shopping_cart_item(%{"sku" => sku, "quantity" => quantity})
       when is_binary(sku) and is_number(quantity) do
    case get_product_and_check_availablity(sku, quantity) do
      {:ok, %Product{} = product} ->
        new_item = %{sku: sku, quantity: quantity, product: Map.from_struct(product)}
        %Ecto.Changeset{valid?: valid?, errors: errors} = Item.changeset(%Item{}, new_item)

        case valid? do
          true ->
            {:ok, Item.create_item(new_item)}

          false ->
            {:error, errors}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp process_shopping_cart_item(_item) do
    {:error, "Invalid item values for sku and quantity"}
  end

  defp get_product_and_check_availablity(sku, quantity) do
    case Catalog.get_product_by_sku(sku) do
      %Product{quantity: existing_product_quantity} = product ->
        new_product_quantity = existing_product_quantity - quantity

        if new_product_quantity < 0 do
          {:error, "Product sku #{sku} is sold out"}
        else
          {:ok, product}
        end

      nil ->
        {:error, "Failed to get product for sku #{sku}"}
    end
  end
end
