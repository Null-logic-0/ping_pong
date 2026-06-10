defmodule PingPong.Service.MockTest do
  use ExUnit.Case, async: true

  test "returns pong for ping payload" do
    assert PingPong.Service.Mock.call(%{message: "Ping!"}, %{}) == {:ok, "Pong! 🏓"}
  end

  test "returns mock error for unsupported payloads" do
    for payload <- [%{}, %{message: "ping"}, %{message: nil}, nil] do
      assert PingPong.Service.Mock.call(payload, %{}) == {:error, {:mock_error, false}}
    end
  end
end
