import Config

sensibo_apikey =
  System.get_env("SENSIBO_APIKEY") ||
    raise """
    SENSIBO_APIKEY was not supplied.
    """

config :sensibo, :api_key, sensibo_apikey

influx_bucket =
  System.get_env("INFLUXDB_BUCKET") ||
    raise """
    INFLUXDB_BUCKET was not supplied.
    """

influx_bucket_token =
  System.get_env("INFLUXDB_BUCKET_TOKEN") ||
    raise """
    INFLUXDB_BUCKET_TOKEN was not supplied.
    """

influx_org =
  System.get_env("INFLUXDB_ORG") ||
    raise """
    INFLUXDB_ORG was not supplied.
    """

influx_host =
  System.get_env("INFLUXDB_HOST") ||
    raise """
    INFLUXDB_HOST was not supplied.
    """

config :sensibo, Sensibo.Influx.Connection,
  auth: [method: :token, token: influx_bucket_token],
  bucket: influx_bucket,
  org: influx_org,
  host: influx_host,
  version: :v2

config :logger, :console, format: "$metadata[$level] $message\n"
