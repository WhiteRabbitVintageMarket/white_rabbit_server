defmodule WhiteRabbitServer.Catalog.GlobalSetup do
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
        Catalog.update_product(product, attrs)

      nil ->
        Catalog.create_product(attrs)
    end
  end
end
