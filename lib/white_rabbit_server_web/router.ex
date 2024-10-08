defmodule WhiteRabbitServerWeb.Router do
  use WhiteRabbitServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WhiteRabbitServerWeb do
    pipe_through :api
    get "/products", ProductController, :index
    get "/orders", OrderController, :index
    get "/browser-safe-client-token", AuthController, :index
    post "/shopping-cart/begin-checkout", ShoppingCartController, :create
    post "/shopping-cart/complete-checkout", ShoppingCartController, :update
  end
end
