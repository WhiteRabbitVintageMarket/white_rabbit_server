defmodule WhiteRabbitServerWeb.AuthController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.PayPalAPI.Client

  action_fallback WhiteRabbitServerWeb.FallbackController

  def index(conn, _params) do
    case Client.get_browser_safe_client_token() do
      {:ok, %{body: body, status: status}} ->
        conn
        |> put_status(status)
        |> render(:index, response: body)

      {:error, %{status: status} = error} ->
        conn
        |> put_status(status)
        |> render(:index, response: error)
    end
  end
end
