# Hornet

Hornet is a simple library for stress testing.

It executes the given function with the given rate (calls per second), dynamically changing the number of processes to maintain the rate.

## Installation

The easiest way to add Hornet to your project is by [using Mix](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html).

Add `:hornet` as a dependency to your project's `mix.exs`:

```elixir
defp deps do
  [
    {:hornet, "~> 0.1.2"}
  ]
end
```

## Usage

To start Hornet use `Hornet.start/1`:

```elixir
params = [rate: 100, func: fn -> 1 + 1 end, id: :add]

Hornet.start(params)
```

It accepts a keyword list.

Required parameters:

- `rate` - the required rate in operations per seconds. For example, 100 (ops/second)
- `func` - the anonymous function that has to be executed. For example, `fn -> 1 + 1 end`
- `id` - atom that will be used for Hornet's process names.

Optional parameters:

- `start_period` - every process executes the given function periodically. This is a starting value for this period. The default value is 100 ms.
- `adjust_step` - if the given rate can no be maintained (for example, if the function is executed too long), Hornet will start increasing the number of processes and the execution period for each process. The period will start increasing by `adjust_step`. The default value is 50ms.
- `adjust_period` - the number of processes is adjusted periodically by `adjust_period` value. The default value is 5_000 ms.
- `error_rate` - allowed rate for difference between the expected rate and the actual rate: `|current_rate - expected_rate| < error_rate * expected_rate`. The default value is 0.1.
- `process_number_limit` - if the given function's execution time is too long and the required rate is high, Hornet will be spawning processes indefinitely. This value will limit the number of processes. The default value is nil.
- `rate_period` - the period of measuring the current rate. The default value is 1_000 ms.
- `log_period` - the interval for the log messages. Disabled by default.

To stop Hornet use `Hornet.stop/1`:

```elixir
:ok = Hornet.stop(:hello)
```

It accepts the pid returned by `Hornet.start/1` or the provided id.

## Contributing

1. [Fork it!](http://github.com/ayrat555/hornet/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Ayrat Badykov (@ayrat555)

## License

Hornet is released under the MIT License. See the LICENSE file for further
details.
