defmodule WhiteRabbitServer.CatalogTest do
  use WhiteRabbitServer.DataCase

  alias WhiteRabbitServer.Catalog

  describe "products" do
    alias WhiteRabbitServer.Catalog.Product

    import WhiteRabbitServer.CatalogFixtures

    @invalid_attrs %{
      name: nil,
      size: nil,
      description: nil,
      image_url: nil,
      sku: nil,
      amount: nil,
      shipping_amount: nil,
      quantity: nil
    }

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{
        name: "some name",
        size: "some size",
        description: "some description",
        image_url: "some url",
        sku: "some sku",
        amount: Money.new(500, :USD),
        shipping_amount: Money.new(100, :USD),
        quantity: 1
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.size == "some size"
      assert product.description == "some description"
      assert product.image_url == "some url"
      assert product.sku == "some sku"
      assert product.amount == Money.new(500, :USD)
      assert product.shipping_amount == Money.new(100, :USD)
      assert product.quantity == 1
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()

      update_attrs = %{
        name: "some updated name",
        size: "some updated size",
        description: "some updated description",
        image_url: "some updated url",
        sku: "some updated sku",
        amount: Money.new(500, :USD),
        shipping_amount: Money.new(100, :USD),
        quantity: 2
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)

      assert product.name == "some updated name"
      assert product.size == "some updated size"
      assert product.description == "some updated description"
      assert product.image_url == "some updated url"
      assert product.sku == "some updated sku"
      assert product.amount == Money.new(500, :USD)
      assert product.shipping_amount == Money.new(100, :USD)
      assert product.quantity == 2
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end
end
