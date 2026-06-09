defmodule PingPong.Service.Telegram do
  @behaviour PingPong.ServiceBehaviour

  @type payload :: %{required(:content) => binary(), required(:chat_id) => binary()}
  @type options :: %{required(:token) => binary()}

  @base_url "https://api.telegram.org"

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

  @spec send_telegram(map(), binary()) :: PingPong.result()
  defp send_telegram(payload, url) do
    body = %{
      chat_id: Map.get(payload, :chat_id),
      text: Map.get(payload, :content)
    }

    json_payload = JSON.encode!(body)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case Req.post(url,
           body: json_payload,
           headers: headers
         ) do
      {:ok, %Req.Response{body: response, status: 200}} ->
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
