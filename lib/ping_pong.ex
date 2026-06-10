defmodule PingPong do
  @moduledoc """
  Public API and OTP application entry point for PingPong.

  PingPong provides a small, consistent interface for sending notifications to
  registered services. The built-in services are `:discord`, `:telegram`, and
  `:mock`; additional services can be registered through application
  configuration.

  ## Results

  Synchronous calls return either `{:ok, response}` or an error tuple. Unknown
  services return `{:error, {:unknown_service, service}}`.

  Asynchronous calls return `{:ok, task}` when a service is found. Awaiting the
  task returns the service result:

      {:ok, task} = PingPong.send_async(:mock, %{message: "Ping!"}, %{})
      Task.await(task)

  """

  use Application

  @typedoc "Notification identifier used by `send_multiple/1`."
  @type id :: atom

  @typedoc "Registered service key, such as `:discord`, `:telegram`, or `:mock`."
  @type service :: atom

  @typedoc "Service-specific notification payload."
  @type payload :: map

  @typedoc "Service-specific delivery options."
  @type options :: map

  @typedoc "Standard result returned by PingPong services."
  @type result :: {:ok, any} | {:error, {atom, any}}

  @typedoc "Delivery mode used by `PingPong.Notification`."
  @type send_type :: :sync | :async

  @typedoc "A notification tuple accepted by `send_multiple/1`."
  @type config :: {service, payload, options}

  @doc false
  def start(_start_type, _start_args) do
    Task.Supervisor.start_link(name: PingPong.Supervisor, max_restarts: 2)
  end

  @doc """
  Sends a notification through a registered service.

  The `payload` and `options` maps are validated by the selected service.

  ## Examples

      iex> PingPong.send(:mock, %{message: "Ping!"}, %{})
      {:ok, "Pong! 🏓"}

      iex> PingPong.send(:unknown, %{}, %{})
      {:error, {:unknown_service, :unknown}}

  """
  @spec send(service(), payload(), options()) :: result()
  defdelegate send(service, payload, options), to: PingPong.Dispatcher, as: :dispatch

  @doc """
  Sends a notification in a supervised task.

  Returns `{:ok, task}` when the service exists. Use `Task.await/1` to receive
  the service result. Unknown services return an error immediately.

  ## Examples

      {:ok, task} = PingPong.send_async(:mock, %{message: "Ping!"}, %{})
      {:ok, "Pong! 🏓"} = Task.await(task)

  """
  @spec send_async(service(), payload(), options()) :: result()
  defdelegate send_async(service, payload, options), to: PingPong.Dispatcher, as: :dispatch_async

  @doc """
  Sends multiple named notifications synchronously.

  Accepts an enumerable of `{id, notification}` pairs, where each notification
  is a `{service, payload, options}` tuple. The return value preserves each
  notification ID alongside its result.

  ## Examples

      notifications = [
        first: {:mock, %{message: "Ping!"}, %{}},
        second: {:mock, %{}, %{}}
      ]

      PingPong.send_multiple(notifications)

  """
  @spec send_multiple(Enumerable.t({id(), config()})) :: [{id(), result()}]
  def send_multiple(notifications) do
    Enum.map(notifications, fn {id, notification} ->
      {id, PingPong.Notification.send_notification(notification, :sync)}
    end)
  end
end
