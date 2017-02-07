defmodule Bonbon.Repo.Migrations.CreateAccount.User do
    use Ecto.Migration

    def change do
        create table(:users) do
            add :email, :string,
                null: false

            add :password_hash, :string,
                null: false

            add :mobile, :string,
                null: false

            add :name, :string,
                null: false

            timestamps
        end
    end
end
