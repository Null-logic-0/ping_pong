defmodule PingPong.NotificationTest do
  use ExUnit.Case, async: true

  test "sends valid notification synchronously" do
    notification = {:mock, %{message: "Ping!"}, %{}}

    assert PingPong.Notification.send_notification(notification, :sync) == {:ok, "Pong! 🏓"}
  end

  test "sends valid notification asynchronously" do
    notification = {:mock, %{message: "Ping!"}, %{}}

    assert {:ok, %Task{} = task} = PingPong.Notification.send_notification(notification, :async)
    assert Task.await(task) == {:ok, "Pong! 🏓"}
  end

  test "returns missing payload error for single-item list" do
    assert PingPong.Notification.send_notification([:mock], :sync) ==
             {:error, {:missing, :payload}}
  end

  test "returns invalid notification for malformed values" do
    invalid_notifications = [
      nil,
      :mock,
      {},
      {:mock},
      {:mock, %{message: "Ping!"}},
      {:mock, %{message: "Ping!"}, nil},
      {"mock", %{message: "Ping!"}, %{}},
      {:mock, "Ping!", %{}}
    ]

    for notification <- invalid_notifications do
      assert PingPong.Notification.send_notification(notification, :sync) ==
               {:error, {:invalid, :notification}}
    end
  end
end
