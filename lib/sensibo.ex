defmodule Sensibo do
  @moduledoc """
  Documentation for `Sensibo`.
  """

  @base_url "https://home.sensibo.com"
  @base_path "/api/v2"

  @api_key_param "apiKey"

  @typep body_type :: binary
  @typep error_type :: binary
  @type response :: {:ok, body_type} | {:error, error_type}

  # end
  # require __MODULE__
  # require Logger

  @doc """
  Hello world.

  ## Examples

      iex> Sensibo.hello()
      :world

  """
  def hello do
  end

  @doc """
  Get all devices.
  """
  def devices_all(api_key \\ api_key()) do
    get("/users/me/pods", api_key, [{"fields", "*"}])
  end

  @doc """
  Get all devices.
  """
  def devices(api_key \\ api_key(), query \\ ["id", "room"]) do
    fields = Enum.join(query, ",")
    get("/users/me/pods", api_key, [{"fields", fields}])
  end

  @doc """
  Get measurements.
  """
  def measurements(pod_uid, api_key \\ api_key()) do
    get("/pods/#{pod_uid}/measurements", api_key)
  end

  @doc """
  Get historical measurements
  """
  def historical_measurements(pod_uid, days \\ 1, api_key \\ api_key()) do
    get("/pods/#{pod_uid}/historicalMeasurements", api_key, days: days)
  end

  @doc """
  """
  def smart_mode(pod_uid, api_key \\ api_key()) do
    get("/pods/#{pod_uid}/smartmode", api_key)
  end

  @doc """
  Get timer
  """
  def timer(pod_uid, api_key \\ api_key()) do
    get("/pods/#{pod_uid}/timer", api_key)
  end

  # def schedules(pod_uid, api_key \\ :system) do
  #   get("/pods/#{pod_uid}/schedules/", api_key)
  # end

  # def pod_measurement(api_key \\ :system) do
  #   get("/users/me/pods", api_key, [{"fields", "id,measurements"}])
  # end

  def ac_state(pod_uid, limit \\ 1, api_key \\ api_key()) do
    get("/pods/#{pod_uid}/acStates", api_key, [{"limit", limit}])
    # get("/pods/#{pod_uid}/acStates", api_key, [{"limit", 1}, {"fields", "acState"}])
  end

  @doc """
  Get custom action as specified
  """
  def custom_action(pod_uid, action, params \\ [], api_key \\ api_key()) do
    get("/pods/#{pod_uid}/#{action}", api_key, params)
  end

  ##
  ## Private
  ##

  # defp get(path, params \\ []) do
  #   params = [{"apiKey", api_key()} | params]

  #   Req.new(base_url: @base_url)
  #   |> Req.Request.put_header("accept", "application/json")
  #   |> Req.get!(url: @base_path <> path, params: params)
  #   |> handle_response()

  #   # %{status: 200, body: body} = response
  # end

  defp get(path, api_key, params \\ []) do
    request(:get, path, api_key, params)
  end

  # defp patch(path, body, api_key, params \\ []) do
  #   request(:patch, path, api_key, body, params)
  # end

  # defmacrop iff(value, expr, fun) do
  #   quote do
  #     if unquote(expr) do
  #       unquote(fun).(unquote(value))
  #     else
  #       unquote(value)
  #     end
  #   end
  # end

  defp request(method, path, api_key, body \\ nil, params) do
    [
      method: method,
      base_url: @base_url,
      url: @base_path <> path,
      headers: [{"accept", "application/json"}],
      params: add_api_key_param(params, api_key)
    ]
    |> maybe_add_body(body)
    |> Req.request()
    |> handle_response()
  end

  defp maybe_add_body(options, nil), do: options
  defp maybe_add_body(options, body), do: [{:body, body} | options]

  defp handle_response(response) do
    case response do
      {:ok, %Req.Response{status: 200, body: %{"status" => "success"} = body}} ->
        {:ok, body["result"]}

      {:ok, %Req.Response{status: 200, body: body}} ->
        {:error, "no success, #{body["result"]}"}

      {:ok, %Req.Response{status: status, body: %{"status" => body_status} = body}} ->
        %{"message" => message, "reason" => reason} = body
        {:error, "status: #{status}:#{body_status}, #{reason}: #{message}"}

      {:ok, %Req.Response{status: 404}} ->
        {:error, "not found"}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "status: #{status}:#{body}"}

      {:error, exception} ->
        raise """
        Sensibo got exception:
        #{inspect(exception)}
        """
    end
  end

  defp add_api_key_param(params, api_key), do: [{@api_key_param, api_key} | params]

  defp api_key() do
    Application.get_env(:sensibo, :api_key) ||
      raise """
      Need to configure and api_key!

      1) config :sensibo, :api_key, "XYZ"

      2) SENSIBO_APIKEY="XYZ"

      """
  end
end
