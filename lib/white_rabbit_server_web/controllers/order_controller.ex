defmodule WhiteRabbitServerWeb.OrderController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.Orders

  action_fallback WhiteRabbitServerWeb.FallbackController

  def index(conn, %{"paypal-order-id" => paypal_order_id}) when is_binary(paypal_order_id) do
    order = Orders.get_order_by_paypal_order_id(paypal_order_id, [:line_items, :products])
    render(conn, :index, order: order)
  end
end
