defmodule PingPong.ServiceBehaviourTest do
  use ExUnit.Case, async: true

  defmodule BehaviourImplementation do
    @behaviour PingPong.ServiceBehaviour

    @impl true
    def call(payload, options), do: {:ok, {payload, options}}
  end

  test "documents the call/2 service contract" do
    assert BehaviourImplementation.call(%{content: "hello"}, %{token: "token"}) ==
             {:ok, {%{content: "hello"}, %{token: "token"}}}
  end
end
