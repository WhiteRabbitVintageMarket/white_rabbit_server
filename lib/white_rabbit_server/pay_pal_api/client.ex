defmodule WhiteRabbitServer.PayPalAPI.Client do
  @behaviour WhiteRabbitServer.PayPalAPI.ClientBehavior

  require Logger

  alias WhiteRabbitServer.PayPalAPI.Config

  @impl WhiteRabbitServer.PayPalAPI.ClientBehavior
  def create_order(body, headers) do
    default_headers = [
      {"Prefer", "return=minimal"},
      {"Content-Type", "application/json"}
    ]

    case Req.post("/v2/checkout/orders",
           base_url: Config.get_base_url(),
           auth: {:bearer, get_oauth_token()},
           headers: Keyword.merge(default_headers, headers),
           json: body
         ) do
      {:ok, %Req.Response{status: status, body: %{"status" => "CREATED"} = body}} ->
        {:ok, %{status: status, body: body}}

      {:ok,
       %Req.Response{
         status: status,
         body: %{"message" => message, "debug_id" => debug_id, "details" => details}
       }} ->
        {:error, %{status: status, message: message, debug_id: debug_id, details: details}}

      _ ->
        {:error, %{status: 500, message: "Unknown error"}}
    end
  end

  @impl WhiteRabbitServer.PayPalAPI.ClientBehavior
  def get_order(order_id, headers) do
    default_headers = [
      {"Prefer", "return=representation"},
      {"Content-Type", "application/json"}
    ]

    case Req.get("/v2/checkout/orders/#{order_id}",
           base_url: Config.get_base_url(),
           auth: {:bearer, get_oauth_token()},
           headers: Keyword.merge(default_headers, headers)
         ) do
      {:ok,
       %Req.Response{status: 200, body: %{"id" => ^order_id, "status" => _order_status} = body}} ->
        {:ok, %{status: 200, body: body}}

      {:ok,
       %Req.Response{
         status: status,
         body: %{"message" => message, "debug_id" => debug_id, "details" => details}
       }} ->
        {:error, %{status: status, message: message, debug_id: debug_id, details: details}}

      _ ->
        {:error, %{status: 500, message: "Unknown error"}}
    end
  end

  @impl WhiteRabbitServer.PayPalAPI.ClientBehavior
  def capture_order(order_id, headers) do
    default_headers = [
      {"Prefer", "return=representation"},
      {"Content-Type", "application/json"}
    ]

    case Req.post("/v2/checkout/orders/#{order_id}/capture",
           base_url: Config.get_base_url(),
           auth: {:bearer, get_oauth_token()},
           headers: Keyword.merge(default_headers, headers)
         ) do
      {:ok,
       %Req.Response{status: status, body: %{"id" => ^order_id, "status" => "COMPLETED"} = body}} ->
        {:ok, %{status: status, body: body}}

      {:ok,
       %Req.Response{
         status: status,
         body: %{"message" => message, "debug_id" => debug_id, "details" => details}
       }} ->
        {:error, %{status: status, message: message, debug_id: debug_id, details: details}}

      _ ->
        {:error, %{status: 500, message: "Unknown error"}}
    end
  end

  @impl WhiteRabbitServer.PayPalAPI.ClientBehavior
  def get_browser_safe_client_token() do
    %{client_id: client_id, client_secret: client_secret} = Config.get_credentials()

    case fetch_oauth_token_from_cache(client_id, client_secret,
           response_type: "client_token",
           intent: "sdk_init"
         ) do
      {:ok, access_token} ->
        Logger.debug("PayPal access_token found in cache")
        {:ok, %{status: 200, body: %{browser_safe_access_token: access_token}}}

      {:commit, access_token, _options} ->
        Logger.debug("Fetching PayPal access_token from api")
        {:ok, %{status: 201, body: %{browser_safe_access_token: access_token}}}

      {:ignore, %{status: status, message: message}} ->
        {:error, %{status: status, message: message}}
    end
  end

  defp get_oauth_token() do
    %{client_id: client_id, client_secret: client_secret} = Config.get_credentials()

    case fetch_oauth_token_from_cache(client_id, client_secret, response_type: "token") do
      {:ok, access_token} ->
        Logger.debug("PayPal access_token found in cache")
        access_token

      {:commit, access_token, _options} ->
        Logger.debug("Fetching PayPal access_token from api")
        access_token
    end
  end

  defp get_oauth_token_from_api(client_id, client_secret, form_body) do
    case Req.post("/v1/oauth2/token",
           base_url: Config.get_base_url(),
           form: Keyword.merge([grant_type: "client_credentials"], form_body),
           auth: {:basic, "#{client_id}:#{client_secret}"}
         ) do
      {:ok, %Req.Response{status: status, body: %{"access_token" => _access_token} = body}} ->
        {:ok, %{status: status, body: body}}

      {:ok,
       %Req.Response{
         status: status,
         body: %{"error" => _error, "error_description" => error_description}
       }} ->
        {:error, %{status: status, message: error_description}}

      _ ->
        {:error, %{status: 500, message: "Unknown error"}}
    end
  end

  defp fetch_oauth_token_from_cache(client_id, client_secret, form_body) do
    response_type = Keyword.fetch!(form_body, :response_type)
    cache_key = "authentication_#{client_id}_#{client_secret}_#{response_type}"

    Cachex.fetch(:payment, cache_key, fn ->
      fetch_oauth_token_from_cache_fallback(client_id, client_secret, form_body)
    end)
  end

  defp fetch_oauth_token_from_cache_fallback(client_id, client_secret, form_body) do
    case get_oauth_token_from_api(client_id, client_secret, form_body) do
      {:ok, %{status: _status, body: body}} ->
        %{"access_token" => access_token, "expires_in" => expires_in} = body
        {:commit, access_token, ttl: :timer.seconds(expires_in)}

      {:error, %{status: status, message: message}} ->
        {:ignore, %{status: status, message: message}}
    end
  end
end
