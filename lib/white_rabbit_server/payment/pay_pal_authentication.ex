defmodule WhiteRabbitServer.Payment.PayPal.Authentication do
  require Logger

  alias WhiteRabbitServer.Payment.PayPal.Config

  def get_oauth_token() do
    %{client_id: client_id, client_secret: client_secret} = Config.get_credentials()

    case fetch_from_cache(client_id, client_secret) do
      {:ok, access_token} ->
        Logger.debug("PayPal access_token found in cache")
        access_token

      {:commit, access_token, _options} ->
        Logger.debug("Fetching PayPal access_token from api")
        access_token
    end
  end

  defp get_from_api(client_id, client_secret) do
    Req.post!("#{Config.get_base_url()}/v1/oauth2/token",
      form: [grant_type: "client_credentials"],
      auth: {:basic, "#{client_id}:#{client_secret}"}
    ).body
  end

  defp fetch_from_cache(client_id, client_secret) do
    cache_key = "authentication_#{client_id}_#{client_secret}"

    Cachex.fetch(:payment, cache_key, fn ->
      %{"access_token" => access_token, "expires_in" => expires_in} =
        get_from_api(client_id, client_secret)

      {:commit, access_token, ttl: :timer.seconds(expires_in)}
    end)
  end
end
