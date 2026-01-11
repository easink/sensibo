import Config

sensibo_apikey =
  System.get_env("SENSIBO_APIKEY") ||
    raise """
    SENSIBO_APIKEY was not supplied.
    """

config :sensibo, :api_key, sensibo_apikey

version = System.get_env("INFLUXDB_VERSION", "v2")

case version do
  "v1" ->
    influx_host =
      System.get_env("INFLUXDB_HOST") ||
        raise """
        INFLUXDB_HOST was not supplied.
        """

    influx_port = System.get_env("INFLUXDB_PORT", "8086") |> String.to_integer()

    influx_v1_database =
      System.get_env("INFLUXDB_V1_DATABASE") ||
        raise """
        INFLUXDB_V1_DATABASE was not supplied.
        """

    # influx_v1_username =
    #   System.get_env("INFLUXDB_V1_USERNAME") ||
    #     raise """
    #     INFLUXDB_V1_USERNAME was not supplied.
    #     """

    # influx_v1_password =
    #   System.get_env("INFLUXDB_V1_PASSWORD") ||
    #     raise """
    #     INFLUXDB_V1_PASSWORD was not supplied.
    #     """

    config :sensibo, Sensibo.Influx.Connection,
      # auth: [username: influx_v1_username, password: influx_v1_password],
      database: influx_v1_database,
      host: influx_host,
      port: influx_port,
      version: :v1

  "v2" ->
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

    influx_port = System.get_env("INFLUXDB_PORT", "8086")

    config :sensibo, Sensibo.Influx.Connection,
      auth: [method: :token, token: influx_bucket_token],
      bucket: influx_bucket,
      org: influx_org,
      host: influx_host,
      port: influx_port,
      version: :v2

  bad_version ->
    raise """
    INFLUXDB_VERSON, #{bad_version} is incorrect.
    """
end

config :logger, :console, format: "$metadata[$level] $message\n"
