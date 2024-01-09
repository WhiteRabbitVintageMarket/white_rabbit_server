defmodule WhiteRabbitServerWeb.ProductControllerTest do
  use WhiteRabbitServerWeb.ConnCase

  import WhiteRabbitServer.CatalogFixtures

  alias WhiteRabbitServer.Catalog.Product

  @create_attrs %{
    name: "some name",
    size: "some size",
    description: "some description",
    url: "some url",
    sku: "some sku",
    price: "some price",
    is_sold: true
  }
  @update_attrs %{
    name: "some updated name",
    size: "some updated size",
    description: "some updated description",
    url: "some updated url",
    sku: "some updated sku",
    price: "some updated price",
    is_sold: false
  }
  @invalid_attrs %{name: nil, size: nil, description: nil, url: nil, sku: nil, price: nil, is_sold: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "is_sold" => true,
               "name" => "some name",
               "price" => "some price",
               "size" => "some size",
               "sku" => "some sku",
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "is_sold" => false,
               "name" => "some updated name",
               "price" => "some updated price",
               "size" => "some updated size",
               "sku" => "some updated sku",
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product}")
      end
    end
  end

  defp create_product(_) do
    product = product_fixture()
    %{product: product}
  end
end
