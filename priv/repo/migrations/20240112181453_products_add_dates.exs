defmodule WhiteRabbitServer.Repo.Migrations.ProductsAddDates do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :posted_at, :utc_datetime
      add :sold_at, :utc_datetime
    end
  end
end
