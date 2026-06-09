defmodule PingPongTest do
  use ExUnit.Case, async: true
  doctest PingPong

  setup_all do
    %{expected_missing_err: {:error, {:missing_required_params}, nil}}
  end

  test "must not work with unknown service" do
    result = PingPong.send(:printer, %{}, %{})

    assert result == {:error, {:unknown_service, :printer}}
  end

  test "must work with payload" do
    result = PingPong.send(:mock, %{message: "Ping!"}, %{})

    assert result == {:ok, "Pong! 🏓"}
  end

  test "must not work with empty payload" do
    result = PingPong.send(:mock, %{}, %{})

    assert result == {:error, {:mock_error, false}}
  end

  test "Discord notification must not work with missing params", %{
    expected_missing_err: expected_missing_err
  } do
    for payload <- [nil, %{}, %{content: "sample"}],
        options <- [nil, %{}, %{webhook: "webhook"}],
        # exclude positive case
        payload != %{content: "sample"} && options != %{webhook: "webhook"} do
      assert expected_missing_err == PingPong.send(:discord, payload, options)
    end
  end

  test "Telegram notification must not work with missing params", %{
    expected_missing_err: expected_missing_err
  } do
    for payload <- [
          nil,
          %{},
          %{content: "sample"},
          %{chat_id: "123"},
          %{content: "sample", chat_id: "123"}
        ],
        options <- [nil, %{}, %{token: "token"}],
        # exclude positive case
        payload != %{content: "sample", chat_id: "123"} || options != %{token: "token"} do
      assert expected_missing_err == PingPong.send(:telegram, payload, options)
    end
  end
end
