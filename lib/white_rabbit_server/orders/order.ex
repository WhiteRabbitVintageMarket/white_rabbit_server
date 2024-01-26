defmodule WhiteRabbitServer.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [
    :gross_amount,
    :net_amount,
    :paypal_fee,
    :paypal_order_id,
    :paypal_update_time,
    :paypal_status,
    :payer_email,
    :payer_full_name,
    :payer_given_name,
    :payer_surname,
    :address_line_1,
    :admin_area_1,
    :admin_area_2,
    :country_code,
    :postal_code
  ]

  schema "orders" do
    field :gross_amount, Money.Ecto.Amount.Type
    field :net_amount, Money.Ecto.Amount.Type
    field :paypal_fee, Money.Ecto.Amount.Type
    field :paypal_order_id, :string
    field :paypal_update_time, :utc_datetime
    field :paypal_status, :string
    field :payer_email, :string
    field :payer_full_name, :string
    field :payer_given_name, :string
    field :payer_surname, :string
    field :address_line_1, :string
    field :admin_area_1, :string
    field :admin_area_2, :string
    field :country_code, :string
    field :postal_code, :string

    has_many :line_items, WhiteRabbitServer.Orders.LineItem
    has_many :products, through: [:line_items, :product]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @attrs)
    |> validate_required(@attrs)
    |> unique_constraint(:paypal_order_id)
  end
end
