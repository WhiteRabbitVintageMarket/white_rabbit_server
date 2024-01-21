defmodule WhiteRabbitServer.PayPalAPI.ClientBehavior do
  @callback create_order(map(), list()) :: {:ok, map()} | {:error, map()}
  @callback get_order(binary(), list()) :: {:ok, map()} | {:error, map()}
  @callback capture_order(binary(), list()) :: {:ok, map()} | {:error, map()}
end
