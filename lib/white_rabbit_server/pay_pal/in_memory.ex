defmodule WhiteRabbitServer.PayPal.InMemory do
  @behaviour WhiteRabbitServer.PayPal.ClientBehavior

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def order_create(_body, _headers) do
    "test/support/fixtures/pay_pal/order_create.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def order_get(_order_id, _headers) do
    "test/fixtures/pay_pal/order_get.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  @impl WhiteRabbitServer.PayPal.ClientBehavior
  def order_capture(_order_id, _headers) do
    "test/fixtures/pay_pal/order_capture.json"
    |> File.read!()
    |> parse_response_from_json()
  end

  defp parse_response_from_json(json) do
    body = Jason.decode!(json)
    {:ok, %{status: 200, body: body}}
  end
end
