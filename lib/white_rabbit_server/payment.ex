defmodule WhiteRabbitServer.Payment do
  alias WhiteRabbitServer.Payment.ShoppingCart
  alias WhiteRabbitServer.Payment.PayPal.Order

  @moduledoc """
  The Payment context.
  """

  @doc """
  Starts the payment process by creating a PayPal order from the buyer's shopping cart.

  ## Examples

      iex> create_order([%{ sku: "RMJ00001", quantity: 1 }, %{ sku: "RMJ00007", quantity: 1 }])
      {:ok, %{body: %{id => "123456"}, status: 201}}

      iex> create_order([%{ sku: "RMJ00001", quantity: 1 }, %{ sku: "RMJ00006", quantity: 1 }])
      {:error, %{message: "", details: [], status: 400}}

  """
  def create_order(shopping_cart) do
    case ShoppingCart.get_products_from_shopping_cart(shopping_cart) do
      {:ok, products} ->
        order_body = create_order_body_payload(products)
        Order.create(order_body)

      {:error, error} ->
        {:error, Map.put_new(error, :status, 400)}
    end
  end

  defp create_order_body_payload(products_with_quantity) do
    currency_code = "USD"

    %{
      intent: "CAPTURE",
      purchase_units: [
        %{
          amount: %{
            currency_code: currency_code,
            value: calculate_grand_total(products_with_quantity),
            breakdown: %{
              item_total: %{
                currency_code: currency_code,
                value: calculate_item_total(products_with_quantity)
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
          items: format_purchase_items(products_with_quantity)
        }
      ]
    }
  end

  defp format_purchase_items(products_with_quantity) do
    Enum.map(products_with_quantity, fn product ->
      %{
        name: String.slice(product.name, 0, 127),
        sku: product.sku,
        description: String.slice(product.description, 0, 127),
        quantity: product.quantity,
        unit_amount: %{
          currency_code: "USD",
          value: Money.to_string(product.amount, symbol: false)
        }
      }
    end)
  end

  defp calculate_grand_total(products_with_quantity) do
    # TODO: add support for shipping cost and tax
    calculate_item_total(products_with_quantity)
  end

  defp calculate_item_total(products_with_quantity) do
    item_total =
      Enum.reduce(products_with_quantity, 0, fn product, acc ->
        total = Money.multiply(product.amount, product.quantity)
        Money.add(total, acc)
      end)

    Money.to_string(item_total, symbol: false)
  end
end
