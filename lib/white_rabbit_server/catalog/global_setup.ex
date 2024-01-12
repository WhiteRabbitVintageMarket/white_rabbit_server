defmodule WhiteRabbitServer.Catalog.GlobalSetup do
  require Logger

  alias WhiteRabbitServer.Catalog.Product
  alias WhiteRabbitServer.Catalog

  def seed() do
    "#{List.to_string(:code.priv_dir(:white_rabbit_server))}/repo/products.json"
    |> get_json
    |> Enum.each(fn attrs -> load_product(attrs) end)
  end

  defp get_json(filename) do
    filename
    |> File.read!()
    |> Jason.decode!()
  end

  defp load_product(attrs = %{"sku" => sku}) do
    case Catalog.get_product_by_sku(sku) do
      %Product{} = product ->
        update_product(product, attrs)

      nil ->
        create_product(attrs)
    end
  end

  defp create_product(attrs = %{"sku" => sku}) do
    case Catalog.create_product(attrs) do
      {:ok, %Product{}} ->
        Logger.info("Successfully created product #{sku}")

      {:error, error_detail} ->
        Logger.error("Failed to create product #{sku}")
        IO.inspect(error_detail)
    end
  end

  defp update_product(%Product{} = product, attrs = %{"sku" => sku}) do
    case Catalog.update_product(product, attrs) do
      {:ok, %Product{}} ->
        Logger.info("Successfully updated product #{sku}")

      {:error, error_detail} ->
        Logger.error("Failed to update product #{sku}")
        IO.inspect(error_detail)
    end
  end
end
