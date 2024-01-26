defmodule WhiteRabbitServerWeb.ProductController do
  use WhiteRabbitServerWeb, :controller

  alias WhiteRabbitServer.Catalog
  alias WhiteRabbitServer.Catalog.Product

  action_fallback WhiteRabbitServerWeb.FallbackController

  def index(conn, %{"sku" => skus}) when is_list(skus) do
    products = Catalog.get_products_by_sku(skus)
    render(conn, :index, products: products)
  end

  def index(conn, _params) do
    products = Catalog.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Catalog.create_product(product_params) do
      conn
      |> put_status(:created)
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)
    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Catalog.get_product!(id)

    with {:ok, %Product{} = product} <- Catalog.update_product(product, product_params) do
      render(conn, :show, product: product)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Catalog.get_product!(id)

    with {:ok, %Product{}} <- Catalog.delete_product(product) do
      send_resp(conn, :no_content, "")
    end
  end
end
