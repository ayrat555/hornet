# Hornet

 Hornet is a simple library for stress testing.

It executes the given function with the given rate (calls per second) dynamically changing the number of processes to maintain the rate.

## Installation

The easiest way to add Hornet to your project is by [using Mix](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html).

Add `:hornet` as a dependency to your project's `mix.exs`:

```elixir
defp deps do
  [
    {:hornet, "~> 0.1.1"}
  ]
end
```

## Documentation

Documentation is [available on Hexdocs](https://hexdocs.pm/hornet/)

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
