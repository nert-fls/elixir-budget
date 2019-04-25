defmodule ExampleWeb.Schema.TransactionTypes do
  use Absinthe.Schema.Notation

  object :transaction do
    field(:id, :id)
    field(:description, :string)
    field(:amount, :integer)
    field(:date, :naive_datetime)
    field(:category_id, :string)

    field :category, :category do
      resolve(&ExampleWeb.Resolvers.Transaction.category_for_transaction/3)
    end
  end
end
