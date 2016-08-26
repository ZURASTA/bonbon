defmodule Bonbon.Allergen do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset

    schema "allergens" do
        translatable :name, Bonbon.Allergen.Name.Translation
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:name])
        |> validate_required([:name])
        |> unique_constraint(:name)
    end
end
