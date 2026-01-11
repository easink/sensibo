defmodule Sensibo.Influx.Measurement do
  @moduledoc false

  use Instream.Series

  series do
    measurement "sensibo"

    tag :id
    tag :name

    field :co2
    field :feels_like
    field :humidity
    field :iaq
    field :rssi
    field :temperature
    field :tvoc
  end

  def from_measurement(id, name, measurement) do
    timestamp =
      measurement["time"]["time"]
      |> NaiveDateTime.from_iso8601!()
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix(:nanosecond)

    %__MODULE__{}
    |> set_tag(:id, id)
    |> set_tag(:name, name || "unknown")
    |> set_field(:co2, measurement["co2"])
    |> set_field(:feels_like, measurement["feelsLike"] |> float())
    |> set_field(:humidity, measurement["humidity"] |> float())
    |> set_field(:iaq, measurement["iaq"])
    |> set_field(:rssi, measurement["rssi"])
    |> set_field(:temperature, measurement["temperature"] |> float())
    |> set_field(:tvoc, measurement["tvoc"])
    |> set_timestamp(timestamp)
  end

  defp set_tag(data, tag, value) do
    %{data | tags: %{data.tags | tag => value}}
  end

  defp set_field(data, field, value) do
    %{data | fields: %{data.fields | field => value}}
  end

  defp set_timestamp(data, timestamp) do
    %{data | timestamp: timestamp}
  end

  defp float(value), do: :erlang.float(value)
end
