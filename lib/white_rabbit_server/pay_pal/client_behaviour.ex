defmodule WhiteRabbitServer.PayPal.ClientBehavior do
  @callback order_create(map(), list()) :: {:ok, map()} | {:error, map()}
  @callback order_get(binary(), list()) :: {:ok, map()} | {:error, map()}
  @callback order_capture(binary(), list()) :: {:ok, map()} | {:error, map()}
end
