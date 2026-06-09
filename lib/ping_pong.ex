defmodule PingPong do
  @moduledoc """
  Documentation for `PingPong`.
  """

  use Application

  @type id :: atom
  @type service :: atom
  @type payload :: map
  @type options :: map
  @type result :: {:ok, any} | {:error, {atom, any}}
  @type send_type :: :sync | :async
  @type config :: {service, payload, options}

  def start(_start_type, _start_args) do
    Task.Supervisor.start_link(name: PingPong.Supervisor, max_restarts: 2)
  end

  @spec send(service, payload, options) :: result
  def send(service, payload, options) do
    handler = Keyword.get(services(), service)

    if is_nil(handler) do
      {:error, {:unknown_service, service}}
    else
      handler.call(payload, options)
    end
  end

  @spec send_async(service, payload, options) :: result
  def send_async(service, payload, options) do
    handler = Keyword.get(services(), service)

    if is_nil(handler) do
      {:error, {:unknown_service, service}}
    else
      task = Task.Supervisor.async(PingPong.Supervisor, fn -> handler.call(payload, options) end)
      {:ok, task}
    end
  end

  @spec send_multiple(any) :: [{PingPong.id(), PingPong.result()}]
  def send_multiple(notification) do
    notification
    |> Enum.map(fn {i, notification} ->
      {i, PingPong.Notification.send_notification(notification, :sync)}
    end)
  end

  @spec services() :: keyword
  def services do
    services = [
      discord: PingPong.Service.Discord,
      telegram: PingPong.Service.Telegram,
      mock: PingPong.Service.Mock
    ]

    # return keyword list
    services
    |> Keyword.merge(Application.get_env(:ping_pong, :services, []))
  end
end
