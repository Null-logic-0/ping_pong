defmodule PingPong.RegistryTest do
  use ExUnit.Case, async: false

  defmodule CustomService do
    @behaviour PingPong.ServiceBehaviour

    def call(payload, options), do: {:ok, {payload, options}}
  end

  setup do
    previous_services = Application.get_env(:ping_pong, :services)

    on_exit(fn ->
      if is_nil(previous_services) do
        Application.delete_env(:ping_pong, :services)
      else
        Application.put_env(:ping_pong, :services, previous_services)
      end
    end)

    :ok
  end

  test "returns built-in services" do
    assert PingPong.Registry.get(:discord) == PingPong.Service.Discord
    assert PingPong.Registry.get(:telegram) == PingPong.Service.Telegram
    assert PingPong.Registry.get(:mock) == PingPong.Service.Mock
  end

  test "returns nil for unknown service" do
    assert PingPong.Registry.get(:unknown) == nil
  end

  test "includes configured services" do
    Application.put_env(:ping_pong, :services, custom: CustomService)

    assert PingPong.Registry.get(:custom) == CustomService
    assert Keyword.fetch!(PingPong.Registry.all(), :custom) == CustomService
  end

  test "configured services override built-ins" do
    Application.put_env(:ping_pong, :services, mock: CustomService)

    assert PingPong.Registry.get(:mock) == CustomService
  end
end
