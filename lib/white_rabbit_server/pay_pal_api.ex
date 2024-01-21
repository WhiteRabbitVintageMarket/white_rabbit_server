defmodule WhiteRabbitServer.PayPalAPI do
  def create_order(body, headers \\ []),
    do: paypal_api_client_implementation().create_order(body, headers)

  def get_order(order_id, headers \\ []),
    do: paypal_api_client_implementation().get_order(order_id, headers)

  def capture_order(order_id, headers \\ []),
    do: paypal_api_client_implementation().capture_order(order_id, headers)

  defp paypal_api_client_implementation() do
    Application.get_env(:white_rabbit_server, :paypal_api_client) ||
      raise "Missing configuration for paypal_api_client. Do you want WhiteRabbitServer.PayPalAPI.Client or WhiteRabbitServer.PayPalAPI.InMemory"
  end
end
