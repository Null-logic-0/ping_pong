defmodule PingPong.Service.Discord do
  @moduledoc """
  Discord webhook notification service.

  This service posts a JSON payload directly to a Discord webhook URL. Discord
  returns HTTP `204` for successful webhook delivery, which is treated as
  `{:ok, response}`.
  """

  @behaviour PingPong.ServiceBehaviour

  @typedoc "Discord webhook payload."
  @type payload :: %{required(:content) => binary()}

  @typedoc "Discord delivery options."
  @type options :: %{required(:webhook) => binary()}

  @doc """
  Sends a Discord message through a webhook.

  Required payload:

      %{content: "Message text"}

  Required options:

      %{webhook: "https://discord.com/api/webhooks/..."}

  Missing required values return `{:error, {:missing_required_params}, nil}`.
  """
  @spec call(payload(), options()) :: PingPong.result()
  def call(payload = _, options = _)
      when not (is_map(payload) and is_map(options) and is_map_key(payload, :content) and
                  is_map_key(options, :webhook)),
      do: {:error, {:missing_required_params}, nil}

  def call(payload, options) do
    webhook = Map.get(options, :webhook)

    send_discord(payload, webhook)
  end

  defp send_discord(payload, url) do
    PingPong.Service.HTTP.post(url, payload, 204)
  end
end
