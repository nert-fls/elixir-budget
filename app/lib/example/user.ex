defmodule Example.User do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "users" do
    field :username, :string
    field :hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
      |> cast(params, [:id, :username, :password, :hash])
      |> validate_required([:username, :password])
      |> unique_constraint(:id, name: :users_pkey, message: "username already exists")
      |> validate_length(:username, min: 4, max: 12, message: "username must be 4-12 characters")
      |> validate_length(:password, min: 8, max: 20, message: "password must be 8-20 characters")
  end

  def transform(users) do
    Enum.each(users, fn(%Example.User{id: id, username: username, hash: hash}) ->
      :ets.insert(:users_table, {id, {username, hash}})
    end)
  end

  def find_with_id(id) do
    case :ets.lookup(:users_table, id) do
      [{_, {username, _}}] ->
        username
      [] ->
        nil
    end
  end

  def find_with_username_and_password(username, password) do
    users = :ets.match(:users_table, {:"$1", :"$2"})

    case Enum.filter(users, fn [_, {k, _}] -> k == username end) do
      [[id, {_username, hash}]] ->
        if Example.Password.verify(password, hash) do
          id
        end
      [] ->
        Example.Password.dummy_verify()
        nil
    end
  end

end
