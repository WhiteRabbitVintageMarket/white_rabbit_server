defmodule WhiteRabbitServer.Payment do
  alias WhiteRabbitServer.PayPal
  alias WhiteRabbitServer.Payment.ShoppingCart
  alias WhiteRabbitServer.Payment.ShoppingCartItem

  @moduledoc """
  The Payment context.
  """

  @doc """
  Starts the payment process by creating a PayPal order from the buyer's shopping cart.

  ## Examples

      iex> create_order([%{"sku" => "RMJ00001", "quantity" => 1}, %{"sku" => "RMJ00007", "quantity" => 1}])
      {:ok, %{body: %{id: "123456"}, status: 201}}

      iex> create_order([%{"sku" => "RMJ00001", "quantity" => 1}, %{"sku" => "RMJ00006", "quantity" => 1}])
      {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}}
  """
  def create_order(shopping_cart) do
    case ShoppingCart.create_shopping_cart_items(shopping_cart) do
      {:ok, shopping_cart_items} ->
        order_body = create_order_body_payload(shopping_cart_items)
        PayPal.create_order(order_body)

      {:error, error} ->
        {:error, Map.put_new(error, :status, 400)}
    end
  end

  def capture_order(order_id) do
    case validate_order(order_id) do
      {:ok, shopping_cart_items} ->
        case PayPal.capture_order(order_id) do
          {:ok, response} ->
            ShoppingCart.update_shopping_cart_items_as_sold(shopping_cart_items)
            {:ok, response}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp create_order_body_payload(shopping_cart_items) do
    currency_code = "USD"

    item_total =
      shopping_cart_items
      |> ShoppingCart.calculate_item_total()
      |> Money.to_string(symbol: false)

    # TODO: add support for shipping and tax
    grand_total = item_total

    %{
      intent: "CAPTURE",
      purchase_units: [
        %{
          amount: %{
            currency_code: currency_code,
            value: grand_total,
            breakdown: %{
              item_total: %{
                currency_code: currency_code,
                value: item_total
              },
              shipping: %{
                currency_code: currency_code,
                value: "0.00"
              },
              tax_total: %{
                currency_code: currency_code,
                value: "0.00"
              }
            }
          },
          items: format_purchase_unit_items(shopping_cart_items)
        }
      ]
    }
  end

  defp format_purchase_unit_items(shopping_cart_items) do
    Enum.map(shopping_cart_items, fn %ShoppingCartItem{} = shopping_cart_item ->
      %ShoppingCartItem{
        name: name,
        sku: sku,
        description: description,
        quantity: quantity,
        amount: amount
      } = shopping_cart_item

      %{
        name: name,
        sku: sku,
        description: description,
        quantity: quantity,
        unit_amount: %{
          currency_code: "USD",
          value: Money.to_string(amount, symbol: false)
        }
      }
    end)
  end

  defp get_purchase_unit_items(%{"purchase_units" => [%{"items" => items}]}) do
    Enum.map(items, fn %{"sku" => sku, "quantity" => quantity} ->
      %{"sku" => sku, "quantity" => quantity}
    end)
  end

  defp validate_order(order_id) do
    case PayPal.get_order(order_id) do
      {:ok, %{body: body}} ->
        shopping_cart_items =
          body
          |> get_purchase_unit_items()
          # verify that none of the products are sold out
          |> ShoppingCart.create_shopping_cart_items()

        shopping_cart_items

      {:error, error} ->
        {:error, error}
    end
  end
end
