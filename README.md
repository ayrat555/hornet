# Hornet

Hornet - a library for stress testing. It dynamically starts multiple processes which execute the given function so the number of executions per second is constant.

## Installation

It's not available on hex.pm yet. So the only way to install it using this repo:

```elixir
def deps do
  [
    {:hornet, git: "https://github.com/ayrat555/hornet"}
  ]
end
```

## Usage

```elixir

func = fn -> "Hello"  end
params = [id: :test, func: func, rate: 10]

{:ok, pid} = Hornet.start(params)

# stops all related processes
:ok = Hornet.stop(:test)
```

## Configuration

Required parameters:

```elixir
    :rate - the required operations per second
    :id - unique id
    :func - the function that has to be executed
```

Optional parameters:

```elixir
    :period - starting period for processes. Each process executes the function periocally using this period. Default value is 100 ms
    :period_step - adjusting step for the period. Default value is 50 ms
    :adjust_period - number of workers and period are adjusted periocally using this value. Default value is 5000 ms
    :error_rate - allowed error rate |expected_rate - actual_rate| / expected_rate < error_rate. Default value is 0.1
```


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/hornet](https://hexdocs.pm/hornet).
