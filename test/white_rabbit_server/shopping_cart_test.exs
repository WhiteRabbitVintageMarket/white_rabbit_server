defmodule WhiteRabbitServer.ShoppingCartTest do
  use WhiteRabbitServer.DataCase

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  alias WhiteRabbitServer.ShoppingCart
  alias WhiteRabbitServer.MockPayPalClient

  describe "shopping_cart" do
    import WhiteRabbitServer.CatalogFixtures

    test "begin_checkout/1 with invalid data returns an error" do
      error = %{message: "Expected shopping_cart to be a list with at least 1 item", status: 400}
      assert {:error, ^error} = ShoppingCart.begin_checkout("bad string data")
      assert {:error, ^error} = ShoppingCart.begin_checkout(123)
      assert {:error, ^error} = ShoppingCart.begin_checkout([])
    end

    test "begin_checkout/1 with invalid shopping cart items returns an error" do
      error = %{message: "Invalid item values for sku and quantity", status: 400}

      assert {:error, ^error} = ShoppingCart.begin_checkout([%{}])
      assert {:error, ^error} = ShoppingCart.begin_checkout([%{"quantity" => 1}])
      assert {:error, ^error} = ShoppingCart.begin_checkout([%{"sku" => "RMJ00001"}])
      assert {:error, ^error} = ShoppingCart.begin_checkout([%{"sku" => 1, "quantity" => 1}])

      assert {:error, ^error} =
               ShoppingCart.begin_checkout([%{"sku" => "RMJ00001", "quantity" => "string"}])
    end

    test "begin_checkout/1 returns an error when quantity is zero" do
      product_fixture(%{sku: "RMJ00001", quantity: 1})

      assert {:error,
              %{
                message: "Invalid shopping_cart items",
                status: 400,
                detail: [
                  quantity:
                    {"is invalid",
                     [
                       validation: :inclusion,
                       enum: %{__struct__: Range, first: 1, last: 10, step: 1}
                     ]}
                ]
              }} = ShoppingCart.begin_checkout([%{"sku" => "RMJ00001", "quantity" => 0}])
    end

    test "begin_checkout/1 with an unknown product sku returns an error" do
      product_fixture(%{sku: "RMJ00006", quantity: 1})

      assert {:error, %{message: "Failed to get product for sku UNKNOWN_SKU", status: 400}} =
               ShoppingCart.begin_checkout([%{"sku" => "UNKNOWN_SKU", "quantity" => 1}])
    end

    test "begin_checkout/1 with a sold out product returns an error" do
      product_fixture(%{sku: "RMJ00006", quantity: 0})

      assert {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}} =
               ShoppingCart.begin_checkout([%{"sku" => "RMJ00006", "quantity" => 1}])
    end

    test "begin_checkout/1 with a valid product creates a paypal order" do
      product_fixture(%{sku: "RMJ00001", quantity: 1})

      expect(MockPayPalClient, :create_order, fn body, _headers ->
        assert %{
                 intent: "CAPTURE",
                 purchase_units: [%{items: [%{sku: "RMJ00001"}], amount: _amount}]
               } =
                 body

        {:ok, %{body: %{"id" => "1DE50048G78128604", "status" => "CREATED"}, status: 200}}
      end)

      assert {:ok, %{body: %{"id" => "1DE50048G78128604", "status" => "CREATED"}, status: 200}} =
               ShoppingCart.begin_checkout([%{"sku" => "RMJ00001", "quantity" => 1}])
    end

    test "complete_checkout/1 with invalid data returns an error" do
      assert {:error, %{message: "Expected paypal_order_id to be a string"}} =
               ShoppingCart.complete_checkout(123)

      assert {:error, %{message: "Expected paypal_order_id to be a string"}} =
               ShoppingCart.complete_checkout([])

      assert {:error, %{message: "Expected paypal_order_id to not be an empty string"}} =
               ShoppingCart.complete_checkout("")
    end

    test "complete_checkout/1 with an unknown paypal_order_id returns an error" do
      expect(MockPayPalClient, :get_order, fn paypal_order_id, _headers ->
        assert paypal_order_id == "123456789_unknown_order_id"

        {:error,
         %{
           status: 404,
           message: "The specified resource does not exist.",
           debug_id: "ae5472ed92fad",
           details: [
             %{
               "description" =>
                 "Specified resource ID does not exist. Please check the resource ID and try again.",
               "issue" => "INVALID_RESOURCE_ID"
             }
           ]
         }}
      end)

      assert {:error, %{status: 404, message: "The specified resource does not exist."}} =
               ShoppingCart.complete_checkout("123456789_unknown_order_id")
    end

    test "complete_checkout/1 with a sold out product returns an error" do
      product_fixture(%{sku: "RMJ00006", quantity: 0})

      expect(MockPayPalClient, :get_order, fn paypal_order_id, _headers ->
        assert paypal_order_id == "123456_ORDER_WITH_SOLD_OUT_ITEM"

        {:ok,
         %{
           status: 200,
           body: %{
             "id" => "123456_ORDER_WITH_SOLD_OUT_ITEM",
             "status" => "COMPLETED",
             "purchase_units" => [
               %{
                 "items" => [
                   %{
                     "quantity" => "1",
                     "sku" => "RMJ00006"
                   }
                 ]
               }
             ]
           }
         }}
      end)

      assert {:error, %{message: "Product sku RMJ00006 is sold out", status: 400}} =
               ShoppingCart.complete_checkout("123456_ORDER_WITH_SOLD_OUT_ITEM")
    end
  end
end
