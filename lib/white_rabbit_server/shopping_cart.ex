defmodule WhiteRabbitServer.ShoppingCart do
  alias WhiteRabbitServer.PayPalAPI
  alias WhiteRabbitServer.ShoppingCart.ShoppingCartClient
  alias WhiteRabbitServer.ShoppingCart.PayPalHelper
  alias WhiteRabbitServer.Orders.ProcessOrder

  @moduledoc """
  The ShoppingCart context.
  """

  @doc """
  Starts the payment process by creating a PayPal order from the buyer's shopping cart.

  ## Examples

      iex> begin_checkout([%{"sku" => "RMJ00001", "quantity" => 1}, %{"sku" => "RMJ00007", "quantity" => 1}])
      {:ok, %{body: %{"id" => "123456", "status" => "CREATED"}, status: 201}}

      iex> begin_checkout([%{"sku" => "RMJ00001", "quantity" => 1}, %{"sku" => "RMJ00006", "quantity" => 1}])
      {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}}
  """
  def begin_checkout(shopping_cart) do
    case ShoppingCartClient.create_shopping_cart_items(shopping_cart) do
      {:ok, shopping_cart_items} ->
        order_body = PayPalHelper.create_order_body_payload(shopping_cart_items)
        PayPalAPI.create_order(order_body)

      {:error, error} ->
        {:error, Map.put_new(error, :status, 400)}
    end
  end

  @doc """
  Completes the payment process by capturing a PayPal order after the buyer approved the payment.

  ## Examples

      iex> complete_checkout("123456")
      {:ok, %{body: %{"id" => "123456", "status" => "COMPLETED"}, status: 200}}

      iex> complete_checkout("123456")
      {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}}
  """
  def complete_checkout(order_id) do
    case ProcessOrder.validate_paypal_order(order_id) do
      {:ok, _products} ->
        case PayPalAPI.capture_order(order_id) do
          {:ok, %{body: body} = response} ->
            ProcessOrder.complete_order(body)
            {:ok, response}

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, Map.put_new(error, :status, 400)}
    end
  end
end
