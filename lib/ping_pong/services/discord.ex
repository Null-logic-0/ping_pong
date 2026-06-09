defmodule PingPong.Service.Discord do
  @behaviour PingPong.ServiceBehaviour
  @type payload :: %{required(:content) => binary()}
  @type options :: %{required(:webhook) => binary()}

  @spec call(payload(), payload()) :: PingPong.result()
  def call(payload = _, options = _)
      when not (is_map(payload) and is_map(options) and is_map_key(payload, :content) and
                  is_map_key(options, :webhook)),
      do: {:error, {:missing_required_params}, nil}

  def call(payload, options) do
    webhook = Map.get(options, :webhook)

    send_discord(payload, webhook)
  end

  @spec send_discord(map, binary) :: PingPong.result()
  defp send_discord(payload, url) do
    json_payload = JSON.encode!(payload)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case Req.post(url,
           body: json_payload,
           headers: headers
         ) do
      {:ok, %Req.Response{body: response, status: 204}} ->
        {:ok, response}

      {:ok, %Req.Response{body: response}} ->
        {:error, {:error_response, response}}

      {:error, %Req.TransportError{reason: reason}} ->
        {:error, {:error, reason}}

      _ = e ->
        {:error, {:unknown_response, e}}
    end
  end
end
