defmodule PingPong.Notification do
  @moduledoc """
  Normalizes notification tuples before dispatching.

  This module is used by `PingPong.send_multiple/1` and is also useful when a
  notification has already been represented as `{service, payload, options}`.
  It validates the tuple shape before delegating to `PingPong.send/3` or
  `PingPong.send_async/3`.
  """

  @doc """
  Sends a notification tuple with the requested delivery mode.

  Valid notifications are three-element tuples:

      {service, payload, options}

  The `service` must be an atom, and both `payload` and `options` must be maps.

  ## Examples

      iex> PingPong.Notification.send_notification({:mock, %{message: "Ping!"}, %{}}, :sync)
      {:ok, "Pong! 🏓"}

      iex> PingPong.Notification.send_notification([:mock], :sync)
      {:error, {:missing, :payload}}

  """
  @spec send_notification(PingPong.config(), PingPong.send_type()) :: PingPong.result()
  def send_notification(notification, send_type) do
    sender = get_sender(send_type)

    case notification do
      {service, payload, options}
      when is_atom(service) and is_map(payload) and is_map(options) ->
        sender.(service, payload, options)

      [_] ->
        {:error, {:missing, :payload}}

      _ ->
        {:error, {:invalid, :notification}}
    end
  end

  defp get_sender(:sync), do: &PingPong.send/3
  defp get_sender(:async), do: &PingPong.send_async/3
end
