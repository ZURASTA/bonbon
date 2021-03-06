defmodule Bonbon.API.Schema.Ingredient do
    use Absinthe.Schema
    use Translecto.Query
    @moduledoc false

    @desc "An ingredient used in food"
    object :ingredient do
        field :id, :id, description: "The id of the ingredient"
        field :name, :string, description: "The name of the ingredient"
        field :type, :string, description: "The culinary type of the ingredient"
    end

    @desc "An ingredient used in food"
    input_object :ingredient_input do
        field :id, :id, description: "The id of the ingredient"
        field :name, :string, description: "The name of the ingredient"
        field :type, :string, description: "The culinary type of the ingredient"
    end

    def get(%{ id: id, locale: locale }, _) do
        query = from ingredient in Bonbon.Model.Ingredient,
            where: ingredient.id == ^id,
            locales: ^Bonbon.Model.Locale.to_locale_id_list!(locale),
            translate: name in ingredient.name,
            translate: type in ingredient.type,
            select: %{
                id: ingredient.id,
                name: name.term,
                type: type.term
            }

        case Bonbon.Repo.one(query) do
            nil -> { :error, "Could not find ingredient" }
            result -> { :ok, result }
        end
    end

    defp query_all(args = %{ find: find }) do
        find = find <> "%"
        where(query_all(Map.delete(args, :find)), [i, n, t],
            ilike(n.term, ^find) or
            ilike(t.term, ^find)
        )
    end
    defp query_all(args = %{ name: name }) do
        name = name <> "%"
        where(query_all(Map.delete(args, :name)), [i, n, t], ilike(n.term, ^name))
    end
    defp query_all(args = %{ type: type }) do
        type = type <> "%"
        where(query_all(Map.delete(args, :type)), [i, n, t], ilike(t.term, ^type))
    end
    defp query_all(%{ locale: locale, limit: limit, offset: offset }) do
        from ingredient in Bonbon.Model.Ingredient,
            locales: ^Bonbon.Model.Locale.to_locale_id_list!(locale),
            translate: name in ingredient.name,
            translate: type in ingredient.type,
            limit: ^limit,
            offset: ^offset, #todo: paginate
            select: %{
                id: ingredient.id,
                name: name.term,
                type: type.term
            }
    end

    def all(args, _) do
        case Bonbon.Repo.all(query_all(args)) do
            nil -> { :error, "Could not retrieve any ingredients" }
            result -> { :ok, result }
        end
    end
end
