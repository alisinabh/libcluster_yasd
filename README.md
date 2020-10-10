# YASD Strategy for libcluster

This is the [YASD](https://github.com/alisinabh/yasd) strategy implementation for libcluster to join Erlang nodes.

## Installation

Add `:libcluster_yasd` to you deps:

```elixir
def deps do
  [
    {:libcluster_yasd, "~> 0.1.0"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/libcluster_yasd](https://hexdocs.pm/libcluster_yasd).

## Usage

Make sure your application is started with correct node name.
Node name should be in format of `{app_name}@{node_ip}` for example `:"my_app@192.168.1.10"`.

To start your app with the correct node name you can use `--name` switch. Example:
```
elixir --name "my_app@192.168.1.10" --cookie "secret_cookie" -S mix run --no-halt
```

NOTE: **All nodes should have the same cookie in order to connect**

```elixir
topologies = [
  my_yasd: [
	strategy: ClusterYASD.Strategy,
	config: [
	  base_url: "http://yaasd:4001" 
	]
  ]
]
```
And finally add it to your supervision tree.

```elixir
{Cluster.Supervisor, [topologies, [name: MyApp.ClusterSupervisor]]}
```

## What is YASD?

Your can learn more about YASD on its github page [github.com/alisinabh/yasd](https://github.com/alisinabh/yasd).

## License

MIT
