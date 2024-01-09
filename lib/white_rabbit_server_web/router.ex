defmodule WhiteRabbitServerWeb.Router do
  use WhiteRabbitServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WhiteRabbitServerWeb do
    pipe_through :api
  end
end
