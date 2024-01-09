defmodule WhiteRabbitServer.Repo do
  use Ecto.Repo,
    otp_app: :white_rabbit_server,
    adapter: Ecto.Adapters.Postgres
end
