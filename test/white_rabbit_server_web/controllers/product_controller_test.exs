defmodule WhiteRabbitServerWeb.ProductControllerTest do
  use WhiteRabbitServerWeb.ConnCase

  import WhiteRabbitServer.CatalogFixtures

  alias WhiteRabbitServer.Catalog.Product

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "returns an empty list when there are no products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end

    test "returns a list of products", %{conn: conn} do
      %Product{sku: sku} = product_fixture()
      conn = get(conn, ~p"/api/products")

      assert [
               %{
                 "description" => "some description",
                 "quantity" => 1,
                 "name" => "some name",
                 "amount" => "1.00",
                 "size" => "some size",
                 "sku" => ^sku,
                 "image_url" => "some url"
               }
             ] = json_response(conn, 200)["data"]
    end
  end
end
