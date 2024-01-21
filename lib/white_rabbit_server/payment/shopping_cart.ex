defmodule WhiteRabbitServer.Payment.ShoppingCart do
  import Ecto.Changeset

  alias WhiteRabbitServer.Catalog
  alias WhiteRabbitServer.Catalog.Product
  alias WhiteRabbitServer.Payment.ShoppingCartItem

  def create_shopping_cart_items(shopping_cart)
      when is_list(shopping_cart) and length(shopping_cart) > 0 do
    case get_shopping_cart_items(shopping_cart) do
      {:ok, shopping_cart_items} ->
        {:ok, shopping_cart_items}

      {:error, [_head | _tail] = errors} ->
        {:error, %{message: "Invalid shopping_cart_items", detail: errors}}

      {:error, error_message} ->
        {:error, %{message: error_message}}
    end
  end

  def create_shopping_cart_items(_shopping_cart) do
    {:error, %{message: "Expected shopping_cart to be a list with at least 1 item"}}
  end

  def calculate_item_total(shopping_cart_items)
      when is_list(shopping_cart_items) and length(shopping_cart_items) > 0 do
    Enum.reduce(shopping_cart_items, 0, fn %ShoppingCartItem{} = shopping_cart_item, acc ->
      %ShoppingCartItem{amount: amount, quantity: quantity} = shopping_cart_item
      total = Money.multiply(amount, quantity)
      Money.add(total, acc)
    end)
  end

  defp create_shopping_cart_item(attrs) do
    %ShoppingCartItem{}
    |> ShoppingCartItem.changeset(attrs)
    |> apply_changes
  end

  defp get_shopping_cart_items(shopping_cart) do
    Enum.reduce_while(shopping_cart, {:ok, []}, fn item, {:ok, items} ->
      %Ecto.Changeset{valid?: valid?, errors: errors} =
        ShoppingCartItem.changeset(%ShoppingCartItem{}, item)

      case valid? do
        true ->
          case load_product_information(item) do
            {:ok, %ShoppingCartItem{} = shopping_cart_item} ->
              {:cont, {:ok, items ++ [shopping_cart_item]}}

            {:error, error} ->
              {:halt, {:error, error}}
          end

        false ->
          {:halt, {:error, errors}}
      end
    end)
  end

  defp load_product_information(%{"sku" => sku, "quantity" => shopping_cart_item_quantity}) do
    case Catalog.get_product_by_sku(sku) do
      %Product{name: name, description: description, amount: amount, quantity: quantity} ->
        if quantity == 0 do
          {:error, "Product sku #{sku} is sold out"}
        else
          attrs = %{
            sku: sku,
            quantity: shopping_cart_item_quantity,
            name: String.slice(name, 0, 127),
            description: String.slice(description, 0, 127),
            amount: amount
          }

          {:ok, create_shopping_cart_item(attrs)}
        end

      nil ->
        {:error, "Failed to get product for sku #{sku}"}
    end
  end
end
