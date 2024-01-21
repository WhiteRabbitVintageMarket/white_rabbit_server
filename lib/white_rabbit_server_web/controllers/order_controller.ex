defmodule WhiteRabbitServerWeb.OrderController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.Payment

  action_fallback WhiteRabbitServerWeb.FallbackController

  def create(conn, %{"cart" => shopping_cart}) do
    case Payment.create_order_for_payment(shopping_cart) do
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

  def update(conn, %{"id" => id}) do
    case Payment.complete_order_for_payment(id) do
      {:ok, %{body: body, status: status}} ->
        conn
        |> put_status(status)
        |> render(:update, response: body)

      {:error, %{status: status} = error} ->
        conn
        |> put_status(status)
        |> render(:update, response: error)
    end
  end
end
