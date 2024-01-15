defmodule WhiteRabbitServer.Payment.PayPal.Config do
  def get_base_url() do
    get_base_url(Application.fetch_env!(:white_rabbit_server, :paypal_environment_mode))
  end

  defp get_base_url("sandbox"), do: "https://api-m.sandbox.paypal.com"
  defp get_base_url("production"), do: "https://api-m.paypal.com"

  def get_credentials() do
    get_credentials(Application.fetch_env!(:white_rabbit_server, :paypal_environment_mode))
  end

  defp get_credentials("sandbox") do
    %{
      client_id: Application.fetch_env!(:white_rabbit_server, :paypal_sandbox_client_id),
      client_secret: Application.fetch_env!(:white_rabbit_server, :paypal_sandbox_client_secret)
    }
  end

  defp get_credentials("production") do
    %{
      client_id: Application.fetch_env!(:white_rabbit_server, :paypal_production_client_id),
      client_secret:
        Application.fetch_env!(:white_rabbit_server, :paypal_production_client_secret)
    }
  end
end
