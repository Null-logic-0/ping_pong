defmodule PingPong.Service.Mock do
  @behaviour PingPong.ServiceBehaviour

  @spec call(map, map) :: {:ok, binary} | {:error, {atom, any}}
  def call(%{message: "Ping!"}, _), do: {:ok, "Pong! 🏓"}
  def call(_, _), do: {:error, {:mock_error, false}}
end
