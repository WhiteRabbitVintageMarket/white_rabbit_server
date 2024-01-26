defmodule WhiteRabbitServerWeb.OrderJSON do
  alias WhiteRabbitServer.Orders.Order
  alias WhiteRabbitServer.Orders.LineItem
  alias WhiteRabbitServer.Catalog.Product

  def index(%{order: %Order{} = order}) do
    order_data(order)
  end

  def index(%{order: nil}), do: %{}

  defp order_data(%Order{
         paypal_order_id: paypal_order_id,
         paypal_status: paypal_status,
         gross_amount: gross_amount,
         paypal_update_time: paypal_update_time,
         payer_given_name: payer_given_name,
         line_items: line_items
       }) do
    %{
      gross_amount: money_to_string(gross_amount),
      paypal_order_id: paypal_order_id,
      paypal_update_time: paypal_update_time,
      paypal_status: paypal_status,
      payer_given_name: payer_given_name,
      line_items: %{data: for(line_item <- line_items, do: line_item_data(line_item))}
    }
  end

  defp line_item_data(%LineItem{
         product: %Product{} = product,
         unit_amount: unit_amount,
         quantity: quantity
       }) do
    %Product{sku: sku, name: name, image_url: image_url} = product

    %{
      sku: sku,
      name: name,
      image_url: image_url,
      unit_amount: money_to_string(unit_amount),
      quantity: quantity
    }
  end

  defp money_to_string(nil), do: ""
  defp money_to_string(amount), do: Money.to_string(amount, symbol: false)
end
