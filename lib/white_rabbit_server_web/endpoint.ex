defmodule WhiteRabbitServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :white_rabbit_server

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_white_rabbit_server_key",
    signing_salt: "yXXhBnIT",
    same_site: "Lax"
  ]

  plug Corsica,
    origins: [
      "http://localhost:8080",
      "http://localhost:4000",
      "https://www.whiterabbitvintagemarket.com",
      "https://www.gregjopa.com",
      "https://cdpn.io"
    ],
    allow_headers: ["Content-Type"]

  # socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :white_rabbit_server,
    gzip: false,
    only: WhiteRabbitServerWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :white_rabbit_server
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug WhiteRabbitServerWeb.Router
end
