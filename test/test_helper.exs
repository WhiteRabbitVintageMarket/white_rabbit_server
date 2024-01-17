ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(WhiteRabbitServer.Repo, :manual)

Mox.defmock(WhiteRabbitServer.MockPayPalClient, for: WhiteRabbitServer.PayPal.ClientBehavior)
Application.put_env(:white_rabbit_server, :paypal_client, WhiteRabbitServer.MockPayPalClient)
