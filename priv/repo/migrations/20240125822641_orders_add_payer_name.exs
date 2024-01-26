defmodule WhiteRabbitServer.Repo.Migrations.OrdersAddPayerName do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :payer_given_name, :string
      add :payer_surname, :string
    end
  end
end
