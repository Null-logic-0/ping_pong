defmodule PingPong.Service.Mock do
  @moduledoc """
  Local test service used for examples and development checks.

  The mock service returns `{:ok, "Pong! 🏓"}` only for
  `%{message: "Ping!"}`. All other payloads return a deterministic mock error.
  """

  @behaviour PingPong.ServiceBehaviour

  @doc """
  Handles a mock notification.

  ## Examples

      iex> PingPong.Service.Mock.call(%{message: "Ping!"}, %{})
      {:ok, "Pong! 🏓"}

      iex> PingPong.Service.Mock.call(%{}, %{})
      {:error, {:mock_error, false}}

  """
  @spec call(map, map) :: {:ok, binary} | {:error, {atom, any}}
  def call(%{message: "Ping!"}, _), do: {:ok, "Pong! 🏓"}
  def call(_, _), do: {:error, {:mock_error, false}}
end
