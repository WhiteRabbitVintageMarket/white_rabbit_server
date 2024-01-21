defmodule WhiteRabbitServer.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :gross_amount, :integer
      add :net_amount, :integer
      add :paypal_fee, :integer
      add :paypal_order_id, :string
      add :paypal_update_time, :utc_datetime
      add :paypal_status, :string
      add :payer_email, :string
      add :payer_full_name, :string
      add :address_line_1, :string
      add :admin_area_1, :string
      add :admin_area_2, :string
      add :country_code, :string
      add :postal_code, :string

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:paypal_order_id], unique: true)
  end
end
