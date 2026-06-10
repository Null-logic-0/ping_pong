defmodule PingPong.ServiceBehaviour do
  @moduledoc """
  Behaviour implemented by PingPong notification services.

  A service receives a payload map and an options map, validates the data it
  needs, performs delivery, and returns a PingPong result tuple.
  """

  @doc """
  Delivers a notification using service-specific payload and options.

  Implementations should return `{:ok, response}` on success and an error tuple
  on failure.
  """
  @callback call(PingPong.payload(), PingPong.options()) :: PingPong.result()
end
