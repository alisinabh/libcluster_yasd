defmodule ClusterYASD do
  @moduledoc """
  Documentation for `ClusterYASD`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ClusterYASD.hello()
      :world

  """
  def hello do
    :world
  end

  def test do
    Supervisor.start_link(
      [{Cluster.Supervisor, [ClusterYASD.topol(), [name: TestCluster.Cluster]]}],
      strategy: :one_for_one,
      name: Test
    )
  end

  def topol do
    [test_yasd: [strategy: ClusterYASD.Strategy, config: [base_url: "http://localhost:4001"]]]
  end
end
