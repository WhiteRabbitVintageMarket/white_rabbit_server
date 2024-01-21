defmodule WhiteRabbitServer.Repo.Migrations.ProductsAddQuantity do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :quantity, :integer
      remove :is_sold
      remove :sold_at
    end
  end
end
