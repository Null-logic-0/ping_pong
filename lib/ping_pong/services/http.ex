defmodule PingPong.Service.HTTP do
  @moduledoc """
  Shared HTTP helper used by network-backed services.

  The helper JSON-encodes request bodies, sends them with `Req`, and normalizes
  HTTP and transport failures into PingPong result tuples. It is intentionally
  small and service-agnostic so service modules can focus on mapping their own
  payloads and options.
  """

  @doc """
  Sends a JSON `POST` request.

  `success_status` defaults to `200`. Services such as Discord can pass a
  different status, for example `204`.

  ## Return values

  - `{:ok, response}` for the expected HTTP status
  - `{:error, {:error_response, response}}` for other HTTP responses
  - `{:error, {:error, reason}}` for transport errors
  - `{:error, {:unknown_response, response}}` for unexpected `Req` results
  """
  @spec post(binary(), map(), integer()) :: PingPong.result()
  def post(url, body, success_status \\ 200) do
    json_payload = JSON.encode!(body)

    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json; charset=utf-8"}
    ]

    case Req.post(url, body: json_payload, headers: headers) do
      {:ok, %Req.Response{body: response, status: ^success_status}} ->
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
