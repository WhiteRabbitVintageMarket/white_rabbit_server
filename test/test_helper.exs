ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(WhiteRabbitServer.Repo, :manual)

Mox.defmock(WhiteRabbitServer.MockPayPalClient, for: WhiteRabbitServer.PayPalAPI.ClientBehavior)
Application.put_env(:white_rabbit_server, :paypal_api_client, WhiteRabbitServer.MockPayPalClient)
