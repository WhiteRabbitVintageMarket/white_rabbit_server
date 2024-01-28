defmodule WhiteRabbitServer.Repo.Migrations.ProductsAddInstagramUrl do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :instagram_url, :string
    end
  end
end
