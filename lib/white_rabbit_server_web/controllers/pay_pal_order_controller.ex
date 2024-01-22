defmodule WhiteRabbitServerWeb.PayPalOrderController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.ShoppingCart

  action_fallback WhiteRabbitServerWeb.FallbackController

  def create(conn, %{"cart" => shopping_cart}) do
    case ShoppingCart.begin_checkout(shopping_cart) do
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
    case ShoppingCart.complete_checkout(id) do
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
