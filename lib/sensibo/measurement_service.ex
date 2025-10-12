defmodule Sensibo.MeasurementService do
  @moduledoc false

  use GenServer
  alias Sensibo.Influx

  require Logger

  @interval_sec 90

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :get_devices}}
  end

  def handle_continue(:get_devices, _devices) do
    {:ok, devices} = Sensibo.devices()

    device_names =
      for device <- devices, into: %{} do
        measure_device_after(device["id"], 0)

        {device["id"], device["room"]["name"]}
      end

    {:noreply, device_names}
  end

  def handle_info({:measure, id}, device_names) do
    case Sensibo.measurements(id) do
      {:ok, [measurement]} ->
        # IO.inspect({id, measurement})

        %{"time" => %{"secondsAgo" => secs_ago}} = measurement
        interval_s = max(@interval_sec - secs_ago + 1, 0)
        # IO.inspect(interval_s)

        Influx.Measurement.from_measurement(id, device_names[id], measurement)
        |> Influx.Connection.write()

        measure_device_after(id, interval_s)

      {:error, reason} ->
        Logger.error(inspect(reason))

        measure_device_after(id, @interval_sec)
    end

    {:noreply, device_names}
  end

  defp measure_device_after(id, after_sec) do
    Process.send_after(self(), {:measure, id}, after_sec * 1000)
  end
end
