defmodule WhiteRabbitServer.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :sku, :string
      add :name, :string
      add :description, :text
      add :size, :string
      add :amount, :integer
      add :shipping_amount, :integer
      add :image_url, :string
      add :is_sold, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
