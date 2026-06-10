defmodule PingPong.Dispatcher do
  @moduledoc """
  Dispatches notifications to registered service modules.

  The dispatcher resolves a service key through `PingPong.Registry` and calls
  the service's `call/2` function. It is the boundary between the public API and
  service implementations.
  """

  @doc """
  Dispatches a notification synchronously.

  Returns `{:error, {:unknown_service, service}}` when no service module is
  registered for the given key.
  """
  @spec dispatch(PingPong.service(), PingPong.payload(), PingPong.options()) :: PingPong.result()
  def dispatch(service, payload, options) do
    case PingPong.Registry.get(service) do
      nil -> {:error, {:unknown_service, service}}
      handler -> handler.call(payload, options)
    end
  end

  @doc """
  Dispatches a notification in a supervised task.

  Returns `{:ok, task}` when the service is known. Awaiting the task returns the
  selected service's result.
  """
  @spec dispatch_async(PingPong.service(), PingPong.payload(), PingPong.options()) ::
          PingPong.result()
  def dispatch_async(service, payload, options) do
    case PingPong.Registry.get(service) do
      nil ->
        {:error, {:unknown_service, service}}

      handler ->
        task =
          Task.Supervisor.async(PingPong.Supervisor, fn -> handler.call(payload, options) end)

        {:ok, task}
    end
  end
end
