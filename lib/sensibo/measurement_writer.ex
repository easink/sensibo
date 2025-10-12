# defmodule Sensibo.MeasurementWriter do
#   use GenServer

#   require Logger

#   def start_link(opts) do
#     GenServer.start_link(__MODULE__, opts, name: __MODULE__)
#   end

#   def init(_opts) do
#     {:ok, []}
#   end

#   def write(server \\ __MODULE__, point) do
#     GenServer.call(server, {:write, point})
#   end

#   def handle_call({:write, point}, state) do
#     {:reply, :ok, state}
#   end
# end
