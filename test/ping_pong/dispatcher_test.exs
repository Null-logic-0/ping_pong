defmodule PingPong.DispatcherTest do
  use ExUnit.Case, async: false

  defmodule CustomService do
    @behaviour PingPong.ServiceBehaviour

    def call(%{reply_to: pid}, options) do
      send(pid, {:custom_service_called, options})
      {:ok, :sent}
    end

    def call(payload, options), do: {:ok, {payload, options}}
  end

  setup do
    previous_services = Application.get_env(:ping_pong, :services)

    Application.put_env(:ping_pong, :services, custom: CustomService)

    on_exit(fn ->
      if is_nil(previous_services) do
        Application.delete_env(:ping_pong, :services)
      else
        Application.put_env(:ping_pong, :services, previous_services)
      end
    end)

    :ok
  end

  test "dispatches known service to registered handler" do
    payload = %{message: "hello"}
    options = %{mode: :test}

    assert PingPong.Dispatcher.dispatch(:custom, payload, options) == {:ok, {payload, options}}
  end

  test "returns unknown service error" do
    assert PingPong.Dispatcher.dispatch(:missing, %{}, %{}) ==
             {:error, {:unknown_service, :missing}}
  end

  test "dispatch_async returns task for known service" do
    assert {:ok, %Task{} = task} =
             PingPong.Dispatcher.dispatch_async(
               :custom,
               %{reply_to: self()},
               %{delivery: :async}
             )

    assert_receive {:custom_service_called, %{delivery: :async}}
    assert Task.await(task) == {:ok, :sent}
  end

  test "dispatch_async returns unknown service error without starting a task" do
    assert PingPong.Dispatcher.dispatch_async(:missing, %{}, %{}) ==
             {:error, {:unknown_service, :missing}}
  end
end
