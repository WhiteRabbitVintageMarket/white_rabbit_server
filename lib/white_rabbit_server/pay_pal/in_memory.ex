defmodule WhiteRabbitServer.PayPal.InMemory do
  @behaviour WhiteRabbitServer.PayPal.ClientBehavior

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def create_order(_body, _headers) do
    "test/support/fixtures/pay_pal/create_order.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def get_order(_order_id, _headers) do
    "test/fixtures/pay_pal/get_order.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def capture_order(_order_id, _headers) do
    "test/fixtures/pay_pal/capture_order.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  defp parse_response_from_json(json) do
    body = Jason.decode!(json)
    {:ok, %{status: 200, body: body}}
  end
end
