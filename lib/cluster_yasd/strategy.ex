defmodule ClusterYASD.Strategy do
  @moduledoc """
  YASD Strategy for libcluster.
  """

  use Cluster.Strategy
  use GenServer

  require Logger

  @default_poll_interval 10
  @default_register_interval 30

  def start_link([state]) do
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(%Cluster.Strategy.State{config: config} = state) do
    [app_name, ip] = get_node_info()
    app_name = Keyword.get(config, :application_name, app_name)

    schedule_next_poll(state)
    send(self(), :register)

    {:ok, Map.put(state, :config, Keyword.merge(config, application_name: app_name, ip: ip))}
  end

  @impl true
  def handle_info(:load, state) do
    with {:ok, nodes} <- get_nodes(state),
         :ok <-
           Cluster.Strategy.connect_nodes(state.topology, state.connect, state.list_nodes, nodes) do
      :ok
    else
      {:error, bad_nodes} ->
        Logger.error("yasd cannot connect: #{inspect(bad_nodes)}")
    end

    schedule_next_poll(state)

    {:noreply, state}
  end

  def handle_info(:register, state) do
    register(state)

    schedule_next_register(state)

    {:noreply, state}
  end

  defp register(%{config: config}) do
    base_url = Keyword.fetch!(config, :base_url)
    app_name = Keyword.fetch!(config, :application_name)
    ip = Keyword.fetch!(config, :ip)

    url = Path.join(base_url, "/api/v1/service/#{app_name}/register?ip=#{ip}")

    case :httpc.request(:put, {to_charlist(url), []}, [], []) do
      {:ok, {{_v, s, _}, _headers, _body}} when s >= 200 and s < 300 ->
        :ok

      {:ok, {{_v, status, _}, _headers, body}} ->
        Logger.error("yasd register error: #{status} -> #{body}")
        {:error, :yasd_error}

      error ->
        Logger.error("yasd register httpc error: #{inspect(error)}")
        {:error, :httpc_error}
    end
  end

  defp get_nodes(%{config: config}) do
    base_url = Keyword.fetch!(config, :base_url)
    app_name = Keyword.fetch!(config, :application_name)

    url = Path.join(base_url, "/api/v1/service/#{app_name}/nodes")

    case :httpc.request(:get, {to_charlist(url), []}, [], []) do
      {:ok, {{_v, s, _}, _headers, body}} when s >= 200 and s < 300 ->
        nodes =
          body
          |> to_string
          |> Jason.decode!()
          |> parse_response(app_name)

        {:ok, nodes}

      {:ok, {{_v, status, _}, _headers, body}} ->
        Logger.error("yasd error: #{status} -> #{body}")
        {:error, :yasd_error}

      error ->
        Logger.error("yasd httpc error: #{inspect(error)}")
        {:error, :httpc_error}
    end
  end

  defp schedule_next_poll(state) do
    Process.send_after(
      self(),
      :load,
      Keyword.get(state.config, :poll_interval, @default_poll_interval) * 1000
    )
  end

  defp schedule_next_register(state) do
    Process.send_after(
      self(),
      :register,
      Keyword.get(state.config, :register_interval, @default_register_interval) * 1000
    )
  end

  defp parse_response(response, app_name) do
    response
    |> Enum.map(&"#{app_name}@#{&1}")
    |> Enum.map(&String.to_atom(&1))
  end

  defp get_node_info do
    Node.self()
    |> to_string()
    |> String.split("@")
  end
end
