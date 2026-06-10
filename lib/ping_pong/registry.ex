defmodule PingPong.Registry do
  @moduledoc """
  Resolves service keys to service modules.

  PingPong ships with built-in `:discord`, `:telegram`, and `:mock` services.
  Applications can add services, or override built-ins, with:

      config :ping_pong,
        services: [
          email: MyApp.EmailService
        ]

  Configured services are merged after built-ins, so a configured key takes
  precedence over a built-in key with the same name.
  """

  @built_in [
    discord: PingPong.Service.Discord,
    telegram: PingPong.Service.Telegram,
    mock: PingPong.Service.Mock
  ]

  @doc """
  Returns the service module registered for `service`.

  Returns `nil` when the service is unknown.
  """
  @spec get(atom()) :: module() | nil
  def get(service) do
    Keyword.get(all(), service)
  end

  @doc """
  Returns all available service registrations.

  The result includes built-in services and services configured under
  `:ping_pong, :services`.
  """
  @spec all() :: keyword()
  def all do
    Keyword.merge(@built_in, Application.get_env(:ping_pong, :services, []))
  end
end
