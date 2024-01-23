defmodule WhiteRabbitServer.ShoppingCart.PayPalHelper do
  alias WhiteRabbitServer.ShoppingCart.Item
  alias WhiteRabbitServer.Catalog.Product

  def create_order_body_payload(items) do
    currency_code = "USD"

    item_total =
      items
      |> calculate_item_total()
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
          items: format_purchase_unit_items(items)
        }
      ]
    }
  end

  def get_items_from_order(%{"purchase_units" => [%{"items" => items}]}) do
    Enum.map(items, fn %{"sku" => sku, "quantity" => quantity} ->
      {quantity_as_integer, _remainder} = Integer.parse(quantity)
      %{"sku" => sku, "quantity" => quantity_as_integer}
    end)
  end

  defp calculate_item_total(items) when is_list(items) and length(items) > 0 do
    Enum.reduce(items, 0, fn %Item{product: %Product{amount: amount}, quantity: quantity}, acc ->
      total = Money.multiply(amount, quantity)
      Money.add(total, acc)
    end)
  end

  defp format_purchase_unit_items(items) do
    Enum.map(items, fn %Item{sku: sku, quantity: quantity, product: product} ->
      %Product{
        name: name,
        description: description,
        amount: amount
      } = product

      %{
        name: String.slice(name, 0, 127),
        sku: sku,
        description: String.slice(description, 0, 127),
        quantity: quantity,
        unit_amount: %{
          currency_code: "USD",
          value: Money.to_string(amount, symbol: false)
        }
      }
    end)
  end
end
