defmodule Sensibo.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Sensibo.Influx.Connection,
      Sensibo.MeasurementService
    ]

    opts = [strategy: :one_for_one, name: Sensibo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
