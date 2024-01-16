defmodule WhiteRabbitServer.PaymentTest do
  use WhiteRabbitServer.DataCase

  alias WhiteRabbitServer.Payment

  describe "orders" do
    # alias WhiteRabbitServer.Catalog.Product

    import WhiteRabbitServer.CatalogFixtures

    test "create_order/1 with invalid list returns an error" do
      error = %{message: "Expected shopping cart to be a list with at least 1 item", status: 400}
      assert {:error, ^error} = Payment.create_order("bad string data")
      assert {:error, ^error} = Payment.create_order(123)
      assert {:error, ^error} = Payment.create_order([])
    end

    test "create_order/1 with invalid shopping cart items returns an error" do
      assert {:error,
              %{
                message: "Invalid shopping cart items",
                status: 400,
                detail: [
                  {:sku, {"can't be blank", [validation: :required]}},
                  {:quantity, {"can't be blank", [validation: :required]}}
                ]
              }} = Payment.create_order([%{}])

      assert {:error,
              %{
                message: "Invalid shopping cart items",
                status: 400,
                detail: [{:sku, {"can't be blank", [validation: :required]}}]
              }} = Payment.create_order([%{"quantity" => 1}])

      assert {:error,
              %{
                message: "Invalid shopping cart items",
                status: 400,
                detail: [{:quantity, {"can't be blank", [validation: :required]}}]
              }} = Payment.create_order([%{"sku" => "RMJ00001"}])

      assert {:error,
              %{
                message: "Invalid shopping cart items",
                status: 400,
                detail: [sku: {"is invalid", [{:type, :string}, {:validation, :cast}]}]
              }} = Payment.create_order([%{"sku" => 1, "quantity" => 1}])

      assert {:error,
              %{
                message: "Invalid shopping cart items",
                status: 400,
                detail: [quantity: {"is invalid", [{:type, :integer}, {:validation, :cast}]}]
              }} = Payment.create_order([%{"sku" => "RMJ00001", "quantity" => "string"}])
    end

    test "create_order/1 with an unknown product sku returns an error" do
      product_fixture(%{sku: "RMJ00006", is_sold: false})

      assert {:error, %{message: "Failed to get product for sku UNKNOWN_SKU", status: 400}} =
               Payment.create_order([%{"sku" => "UNKNOWN_SKU", "quantity" => 1}])
    end

    test "create_order/1 with sold out product returns an error" do
      product_fixture(%{sku: "RMJ00006", is_sold: true})

      assert {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}} =
               Payment.create_order([%{"sku" => "RMJ00006", "quantity" => 1}])
    end

    test "create_order/1 with a valid product creates a paypal order" do
      product_fixture(%{sku: "RMJ00001", is_sold: false})

      assert {:ok, %{body: %{"id" => "1DE50048G78128604", "status" => "CREATED"}, status: 200}} =
               Payment.create_order([%{"sku" => "RMJ00001", "quantity" => 1}])
    end
  end
end
