defmodule WhiteRabbitServerWeb.OrderController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.Payment

  action_fallback WhiteRabbitServerWeb.FallbackController

  def create(conn, %{"_json" => shopping_cart}) do
    case Payment.create_order(shopping_cart) do
      {:ok, %{body: body, status: status}} ->
        conn
        |> put_status(status)
        |> render(:create, response: body)

      {:error, %{status: status} = error} ->
        conn
        |> put_status(status)
        |> render(:create, response: error)
    end
  end
end
