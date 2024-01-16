defmodule WhiteRabbitServer.PayPal do
  def order_create(body, headers \\ []),
    do: paypal_client_implementation().order_create(body, headers)

  def order_get(order_id, headers \\ []),
    do: paypal_client_implementation().order_get(order_id, headers)

  def order_capture(order_id, headers \\ []),
    do: paypal_client_implementation().order_capture(order_id, headers)

  defp paypal_client_implementation() do
    Application.get_env(:white_rabbit_server, :paypal_client) ||
      raise "Missing configuration for PayPal. Do you want WhiteRabbitServer.PayPal.Client or WhiteRabbitServer.PayPal.InMemory"
  end
end
