defmodule Bonbon.Endpoint do
    use Phoenix.Endpoint, otp_app: :bonbon

    # Code reloading can be explicitly enabled under the
    # :code_reloader configuration of your endpoint.
    if code_reloading? do
        plug Phoenix.CodeReloader
    end

    plug Plug.RequestId
    plug Plug.Logger

    if Mix.env == :dev do #todo: likely make prod a wildcard
        plug Corsica,
            origins: "http://localhost:8000",
            allow_headers: [
                "origin",
                "content-type",
                "accept-language",
                "accept",
                "authorization"
            ]
    end

    plug Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
        pass: ["*/*"],
        json_decoder: Poison

    plug Bonbon.API.Context

    plug if(Mix.env != :dev, do: Absinthe.Plug, else: Absinthe.Plug.GraphiQL),
        schema: Bonbon.API.Schema
end
