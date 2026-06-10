defmodule PingPong.Service.Telegram do
  @moduledoc """
  Telegram Bot API notification service.

  This service sends text messages through Telegram's `sendMessage` endpoint.
  The public PingPong payload uses `:content`; the service maps it to Telegram's
  `text` field before sending the request.
  """

  @behaviour PingPong.ServiceBehaviour

  @typedoc "Telegram notification payload."
  @type payload :: %{required(:content) => binary(), required(:chat_id) => binary()}

  @typedoc "Telegram delivery options."
  @type options :: %{required(:token) => binary()}

  @base_url "https://api.telegram.org"

  @doc """
  Sends a Telegram message.

  Required payload:

      %{
        content: "Message text",
        chat_id: "123456789"
      }

  Required options:

      %{token: "123456:telegram-bot-token"}

  Missing required values return `{:error, {:missing_required_params}, nil}`.
  """
  @spec call(payload(), options()) :: PingPong.result()
  def call(payload = _, options = _)
      when not (is_map(payload) and is_map(options) and is_map_key(payload, :content) and
                  is_map_key(payload, :chat_id) and is_map_key(options, :token)),
      do: {:error, {:missing_required_params}, nil}

  def call(payload, options) do
    token = Map.get(options, :token)
    url = "#{@base_url}/bot#{token}/sendMessage"
    send_telegram(payload, url)
  end

  defp send_telegram(payload, url) do
    body = %{
      chat_id: Map.get(payload, :chat_id),
      text: Map.get(payload, :content)
    }

    PingPong.Service.HTTP.post(url, body)
  end
end
