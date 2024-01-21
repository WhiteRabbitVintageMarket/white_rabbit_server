defmodule WhiteRabbitServer.OrdersFixtures do
  alias WhiteRabbitServer.CatalogFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `WhiteRabbitServer.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        address_line_1: "some address_line_1",
        admin_area_1: "some admin_area_1",
        admin_area_2: "some admin_area_2",
        country_code: "some country_code",
        gross_amount: Money.new(100, :USD),
        net_amount: Money.new(100, :USD),
        payer_email: "some payer_email",
        payer_full_name: "some payer_full_name",
        paypal_fee: Money.new(100, :USD),
        paypal_order_id: Ecto.UUID.generate(),
        paypal_status: "some paypal_status",
        paypal_update_time: ~U[2024-01-18 03:22:00Z],
        postal_code: "some postal_code"
      })
      |> WhiteRabbitServer.Orders.create_order()

    order
  end

  @doc """
  Generate a line_item.
  """
  def line_item_fixture(attrs \\ %{}) do
    order = order_fixture()
    product = CatalogFixtures.product_fixture()

    {:ok, line_item} =
      attrs
      |> Enum.into(%{
        quantity: 1,
        unit_amount: Money.new(100, :USD),
        product_id: product.id,
        order_id: order.id
      })
      |> WhiteRabbitServer.Orders.create_line_item()

    line_item
  end
end
