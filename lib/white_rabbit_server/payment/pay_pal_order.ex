defmodule WhiteRabbitServer.Payment.PayPal.Order do
  alias WhiteRabbitServer.Payment.PayPal.Config
  alias WhiteRabbitServer.Payment.PayPal.Authentication

  def create(body, headers \\ %{}) do
    access_token = Authentication.get_oauth_token()
    default_headers = %{Prefer => "return=minimal"}

    # TODO: look into using mox

    case Req.post("#{Config.get_base_url()}/v2/checkout/orders",
           auth: {:bearer, access_token},
           json: body,
           headers: Map.merge(default_headers, headers)
         ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, %{status: 200, body: body}}

      {:ok, %Req.Response{status: 201, body: body}} ->
        {:ok, %{status: 201, body: body}}

      {:ok, %Req.Response{status: error_status, body: body}} ->
        %{"message" => message, "debug_id" => debug_id, "details" => details} = body
        {:error, %{status: error_status, message: message, debug_id: debug_id, details: details}}

      _ ->
        {:error, %{status: 500, message: "Unknown error"}}
    end
  end

  def capture(order_id, headers \\ %{}) do
    access_token = Authentication.get_oauth_token()

    default_headers = %{
      Prefer => "return=representation",
      "Content-Type" => "application/json"
    }

    Req.post("#{Config.get_base_url()}/v2/checkout/orders/#{order_id}/capture",
      auth: {:bearer, access_token},
      headers: Map.merge(default_headers, headers)
    )
  end
end
