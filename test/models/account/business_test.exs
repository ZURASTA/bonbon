defmodule Bonbon.Model.Account.BusinessTest do
    use Bonbon.ModelCase

    alias Bonbon.Model.Account.Business

    @valid_model %Business{
        email: "email@example.com",
        name: "Foo Bar",
        password: "test",
        password_hash: "test",
        mobile: "+123456789"
    }

    test "empty" do
        refute_change(%Business{}, %{}, :registration_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "only email" do
        refute_change(%Business{}, %{ email: @valid_model.email }, :registration_changeset)

        assert_change(@valid_model, %{ email: "foo@bar" }, :update_changeset)
    end

    test "only name" do
        refute_change(%Business{}, %{ name: @valid_model.name }, :registration_changeset)

        assert_change(@valid_model, %{ name: "test" }, :update_changeset)
    end

    test "only mobile" do
        refute_change(%Business{}, %{ mobile: @valid_model.mobile }, :registration_changeset)

        assert_change(@valid_model, %{ mobile: "+123" }, :update_changeset)
    end

    test "only password" do
        refute_change(%Business{}, %{ password: @valid_model.password }, :registration_changeset)

        assert_change(@valid_model, %{ password: "new" }, :update_changeset)
    end

    test "without email" do
        refute_change(@valid_model, %{ email: nil }, :registration_changeset)
    end

    test "without name" do
        refute_change(@valid_model, %{ name: nil }, :registration_changeset)
    end

    test "without mobile" do
        refute_change(@valid_model, %{ mobile: nil }, :registration_changeset)
    end

    test "without password" do
        refute_change(@valid_model, %{ password: nil }, :registration_changeset)
    end

    test "valid model" do
        assert_change(@valid_model, %{}, :registration_changeset)

        assert_change(@valid_model, %{}, :update_changeset)
    end

    test "email formatting" do
        refute_change(@valid_model, %{ email: "test" }, :registration_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "@" }, :registration_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test@" }, :registration_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "@" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })

        refute_change(@valid_model, %{ email: "test@" }, :update_changeset)
        |> assert_error_value(:email, { "should contain a local part and domain separated by '@'", [validation: :email] })
    end

    test "mobile formatting" do
        refute_change(@valid_model, %{ mobile: "123" }, :registration_changeset)
        |> assert_error_value(:mobile, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+123a" }, :registration_changeset)
        |> assert_error_value(:mobile, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+" }, :registration_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+1234567890123456789" }, :registration_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "123" }, :update_changeset)
        |> assert_error_value(:mobile, { "should begin with a country prefix", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+123a" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain the country prefix followed by only digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })

        refute_change(@valid_model, %{ mobile: "+1234567890123456789" }, :update_changeset)
        |> assert_error_value(:mobile, { "should contain between 1 and 18 digits", [validation: :phone_number] })
    end

    test "password hashing" do
        assert_change(@valid_model, %{}, :registration_changeset)
        |> refute_change_field(:password_hash)

        assert_change(@valid_model, %{ password: "pass" }, :registration_changeset)
        |> assert_change_field(:password_hash)

        assert_change(@valid_model, %{}, :update_changeset)
        |> refute_change_field(:password_hash)

        assert_change(@valid_model, %{ password: "pass" }, :update_changeset)
        |> assert_change_field(:password_hash)
    end

    test "uniqueness" do
        user = Bonbon.Repo.insert!(@valid_model)

        assert_change(@valid_model, %{ email: @valid_model.email }, :registration_changeset)
        |> assert_insert(:error)
        |> assert_error_value(:email, { "has already been taken", [] })

        assert_change(@valid_model, %{ email: @valid_model.email <> ".test" }, :registration_changeset)
        |> assert_insert(:ok)

        assert_change(@valid_model, %{ email: "test" <> @valid_model.email }, :registration_changeset)
        |> assert_insert(:ok)
    end

    test "authenticate" do
        user_foo = Bonbon.Repo.insert!(Business.registration_changeset(%Business{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))
        user_bar = Bonbon.Repo.insert!(Business.registration_changeset(%Business{}, %{ email: "bar@bar", password: "test", name: "bar", mobile: "+123" }))

        assert { :ok, %{ user_foo | password: nil } } == Bonbon.Model.Account.authenticate(Business, email: "foo@foo", password: "test")
        assert { :ok, %{ user_bar | password: nil } } == Bonbon.Model.Account.authenticate(Business, email: "bar@bar", password: "test")
    end

    test "update" do
        user_foo = Bonbon.Repo.insert!(Business.registration_changeset(%Business{}, %{ email: "foo@foo", password: "test", name: "foo", mobile: "+123" }))

        assert { :ok, %{ name: "new" } } = Bonbon.Repo.update(Business.update_changeset(user_foo, %{ name: "new" }))
        assert { :ok, %{ mobile: "+00" } } = Bonbon.Repo.update(Business.update_changeset(user_foo, %{ mobile: "+00" }))
        assert { :ok, %{ email: "a@a" } } = Bonbon.Repo.update(Business.update_changeset(user_foo, %{ email: "a@a" }))

        assert { :ok, user } = Bonbon.Repo.update(Business.update_changeset(user_foo, %{ password: "new" }))
        assert user.password_hash != user_foo.password_hash
    end
end
