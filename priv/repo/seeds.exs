# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WhiteRabbitServer.Repo.insert!(%WhiteRabbitServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WhiteRabbitServer.Repo
alias WhiteRabbitServer.Catalog.Product

Repo.insert!(%Product{
  sku: "RMJ00001",
  name: "1950’s Solid Brass Golden Retriever Music Box made by Leonard Silver Co.",
  description:
    "This rare find is in working condition. Some patina on one side of the dogs face. Beautiful piece to add to your shelves or a child’s room.",
  size: "about 4 1/2 inches tall",
  amount: Money.parse!("$42.00", :USD),
  shipping_amount: Money.parse!("$8.00", :USD),
  image_url:
    "https://www.whiterabbitvintagemarket.com/images/products/brass-golden-retriever-music-box.jpeg",
  is_sold: false
})
