defmodule WhiteRabbitServer.Orders.ProcessOrder do
  require Logger

  alias WhiteRabbitServer.PayPal
  alias WhiteRabbitServer.Catalog
  alias WhiteRabbitServer.Catalog.Product
  alias WhiteRabbitServer.Orders
  alias WhiteRabbitServer.Orders.Order
  alias WhiteRabbitServer.Orders.LineItem

  def complete_order(paypal_order) do
    %{order: order, items: items} = get_order_attrs(paypal_order)

    # TODO: add error handling for this

    {:ok, %Order{} = created_order} = Orders.create_order(order)
    line_items = create_line_items(created_order, items)
    update_product_quantities(line_items)
  end

  def validate_paypal_order(paypal_order_id) do
    case PayPal.get_order(paypal_order_id) do
      {:ok, %{body: body}} ->
        validate_purchase_unit_items(body)

      {:error, error} ->
        {:error, error}
    end
  end

  defp create_line_items(%Order{id: order_id}, purchased_items) do
    Enum.map(purchased_items, fn %{"sku" => sku, "quantity" => quantity} ->
      %Product{id: product_id, amount: amount} = Catalog.get_product_by_sku(sku)

      {:ok, %LineItem{} = line_item} =
        Orders.create_line_item(%{
          order_id: order_id,
          product_id: product_id,
          unit_amount: amount,
          quantity: quantity
        })

      line_item
    end)
  end

  defp get_order_attrs(paypal_order) do
    %{
      "id" => id,
      "status" => status,
      "update_time" => update_time,
      "payer" => %{
        "email_address" => email
      },
      "purchase_units" => [%{"items" => items, "payments" => payments, "shipping" => shipping}]
    } = paypal_order

    %{
      "captures" => [
        %{
          "seller_receivable_breakdown" => %{
            "gross_amount" => %{"value" => gross_amount},
            "net_amount" => %{"value" => net_amount},
            "paypal_fee" => %{"value" => paypal_fee}
          }
        }
      ]
    } = payments

    %{
      "address" => %{
        "address_line_1" => address_line_1,
        "admin_area_1" => admin_area_1,
        "admin_area_2" => admin_area_2,
        "country_code" => country_code,
        "postal_code" => postal_code
      },
      "name" => %{"full_name" => full_name}
    } = shipping

    order = %{
      gross_amount: gross_amount,
      net_amount: net_amount,
      paypal_fee: paypal_fee,
      paypal_order_id: id,
      paypal_update_time: update_time,
      paypal_status: status,
      payer_email: email,
      payer_full_name: full_name,
      address_line_1: address_line_1,
      admin_area_1: admin_area_1,
      admin_area_2: admin_area_2,
      country_code: country_code,
      postal_code: postal_code
    }

    %{order: order, items: items}
  end

  defp update_product_quantities(line_items) do
    line_items
    |> Enum.map(fn %LineItem{id: id} ->
      %LineItem{product: product, quantity: quantity} = Orders.get_line_item!(id, [:product])
      %LineItem{product: product, quantity: quantity}
    end)
    |> Enum.each(fn %LineItem{product: product, quantity: line_item_quantity} ->
      %Product{sku: sku, quantity: product_quantity} = product
      updated_product_quantity = product_quantity - line_item_quantity

      case Catalog.update_product(product, %{quantity: updated_product_quantity}) do
        {:ok, %Product{}} ->
          Logger.debug("Product #{sku} quantity has been updated to #{updated_product_quantity}")

        {:error, _error} ->
          Logger.error("Failed to update product #{sku} quantity to #{updated_product_quantity}")
      end
    end)
  end

  defp validate_purchase_unit_items(%{"purchase_units" => [%{"items" => items}]}) do
    Enum.reduce_while(items, {:ok, []}, fn item, {:ok, products} ->
      %{"sku" => sku, "quantity" => _quantity} = item

      case Catalog.get_product_by_sku(sku) do
        %Product{quantity: quantity} = product ->
          if quantity == 0 do
            {:halt, {:error, "Product sku #{sku} is sold out"}}
          else
            {:cont, {:ok, products ++ [product]}}
          end

        nil ->
          {:halt, {:error, "Failed to get product for sku #{sku}"}}
      end
    end)
  end
end
