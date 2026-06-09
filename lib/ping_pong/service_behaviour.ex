defmodule PingPong.ServiceBehaviour do
  @callback call(PingPong.payload(), PingPong.options()) :: PingPong.result()
end
