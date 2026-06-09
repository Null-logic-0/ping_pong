defmodule PingPong.Notification do
  @spec send_notification(PingPong.config(), PingPong.send_type()) :: PingPong.result()
  def send_notification(notification, send_type) do
    # fetch sender
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

  # sender mappings
  defp get_sender(:sync), do: &PingPong.send/3
  defp get_sender(:async), do: &PingPong.send_async/3
end
