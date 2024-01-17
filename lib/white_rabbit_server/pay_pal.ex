defmodule WhiteRabbitServer.PayPal do
  def create_order(body, headers \\ []),
    do: paypal_client_implementation().create_order(body, headers)

  def get_order(order_id, headers \\ []),
    do: paypal_client_implementation().get_order(order_id, headers)

  def capture_order(order_id, headers \\ []),
    do: paypal_client_implementation().capture_order(order_id, headers)

  defp paypal_client_implementation() do
    Application.get_env(:white_rabbit_server, :paypal_client) ||
      raise "Missing configuration for PayPal. Do you want WhiteRabbitServer.PayPal.Client or WhiteRabbitServer.PayPal.InMemory"
  end
end
