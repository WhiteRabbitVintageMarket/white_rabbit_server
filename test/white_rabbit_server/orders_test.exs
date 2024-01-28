defmodule WhiteRabbitServer.OrdersTest do
  use WhiteRabbitServer.DataCase

  alias WhiteRabbitServer.Orders
  alias WhiteRabbitServer.Orders.Order

  describe "orders" do
    import WhiteRabbitServer.OrdersFixtures

    @invalid_attrs %{
      gross_amount: nil,
      net_amount: nil,
      paypal_fee: nil,
      paypal_order_id: nil,
      paypal_update_time: nil,
      paypal_status: nil,
      payer_email: nil,
      payer_full_name: nil,
      address_line_1: nil,
      admin_area_1: nil,
      admin_area_2: nil,
      country_code: nil,
      postal_code: nil
    }

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{
        gross_amount: Money.new(100, :USD),
        net_amount: Money.new(100, :USD),
        paypal_fee: Money.new(100, :USD),
        paypal_order_id: "some paypal_order_id",
        paypal_update_time: ~U[2024-01-18 03:22:00Z],
        paypal_status: "some paypal_status",
        payer_email: "some payer_email",
        payer_full_name: "some payer_full_name",
        payer_given_name: "some payer_given_name",
        payer_surname: "some payer_surname",
        address_line_1: "some address_line_1",
        admin_area_1: "some admin_area_1",
        admin_area_2: "some admin_area_2",
        country_code: "some country_code",
        postal_code: "some postal_code"
      }

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.gross_amount == Money.new(100, :USD)
      assert order.net_amount == Money.new(100, :USD)
      assert order.paypal_fee == Money.new(100, :USD)
      assert order.paypal_order_id == "some paypal_order_id"
      assert order.paypal_update_time == ~U[2024-01-18 03:22:00Z]
      assert order.paypal_status == "some paypal_status"
      assert order.payer_email == "some payer_email"
      assert order.payer_full_name == "some payer_full_name"
      assert order.address_line_1 == "some address_line_1"
      assert order.admin_area_1 == "some admin_area_1"
      assert order.admin_area_2 == "some admin_area_2"
      assert order.country_code == "some country_code"
      assert order.postal_code == "some postal_code"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()

      update_attrs = %{
        gross_amount: Money.new(100, :USD),
        net_amount: Money.new(100, :USD),
        paypal_fee: Money.new(100, :USD),
        paypal_order_id: "some updated paypal_order_id",
        paypal_update_time: ~U[2024-01-19 03:22:00Z],
        paypal_status: "some updated paypal_status",
        payer_email: "some updated payer_email",
        payer_full_name: "some updated payer_full_name",
        address_line_1: "some updated address_line_1",
        admin_area_1: "some updated admin_area_1",
        admin_area_2: "some updated admin_area_2",
        country_code: "some updated country_code",
        postal_code: "some updated postal_code"
      }

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.gross_amount == Money.new(100, :USD)
      assert order.net_amount == Money.new(100, :USD)
      assert order.paypal_fee == Money.new(100, :USD)
      assert order.paypal_order_id == "some updated paypal_order_id"
      assert order.paypal_update_time == ~U[2024-01-19 03:22:00Z]
      assert order.paypal_status == "some updated paypal_status"
      assert order.payer_email == "some updated payer_email"
      assert order.payer_full_name == "some updated payer_full_name"
      assert order.address_line_1 == "some updated address_line_1"
      assert order.admin_area_1 == "some updated admin_area_1"
      assert order.admin_area_2 == "some updated admin_area_2"
      assert order.country_code == "some updated country_code"
      assert order.postal_code == "some updated postal_code"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end

  describe "order_line_items" do
    alias WhiteRabbitServer.Orders.LineItem
    alias WhiteRabbitServer.CatalogFixtures
    alias WhiteRabbitServer.Catalog.Product

    import WhiteRabbitServer.OrdersFixtures

    @invalid_attrs %{unit_amount: nil, quantity: nil}

    test "list_order_line_items/0 returns all order_line_items" do
      line_item = line_item_fixture()
      assert Orders.list_order_line_items() == [line_item]
    end

    test "get_line_item!/1 returns the line_item with given id" do
      line_item = line_item_fixture()
      assert Orders.get_line_item!(line_item.id) == line_item
    end

    test "create_line_item/1 with valid data creates a line_item" do
      %Order{id: order_id} = order_fixture()
      %Product{id: product_id} = CatalogFixtures.product_fixture()

      valid_attrs = %{
        unit_amount: Money.new(100, :USD),
        quantity: 1,
        order_id: order_id,
        product_id: product_id
      }

      assert {:ok, %LineItem{} = line_item} = Orders.create_line_item(valid_attrs)
      assert line_item.unit_amount == Money.new(100, :USD)
      assert line_item.quantity == 1
    end

    test "create_line_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_line_item(@invalid_attrs)
    end

    test "update_line_item/2 with valid data updates the line_item" do
      line_item = line_item_fixture()
      update_attrs = %{unit_amount: Money.new(200, :USD), quantity: 2}

      assert {:ok, %LineItem{} = line_item} = Orders.update_line_item(line_item, update_attrs)
      assert line_item.unit_amount == Money.new(200, :USD)
      assert line_item.quantity == 2
    end

    test "update_line_item/2 with invalid data returns error changeset" do
      line_item = line_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_line_item(line_item, @invalid_attrs)
      assert line_item == Orders.get_line_item!(line_item.id)
    end

    test "delete_line_item/1 deletes the line_item" do
      line_item = line_item_fixture()
      assert {:ok, %LineItem{}} = Orders.delete_line_item(line_item)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_line_item!(line_item.id) end
    end

    test "change_line_item/1 returns a line_item changeset" do
      line_item = line_item_fixture()
      assert %Ecto.Changeset{} = Orders.change_line_item(line_item)
    end
  end
end
