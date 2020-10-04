defmodule Hornet.Worker do
  use GenServer

  alias Hornet.RateCounter

  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl true
  def init(params) do
    func = Keyword.fetch!(params, :func)
    interval = Keyword.fetch!(params, :interval)
    rate_counter = Keyword.fetch!(params, :rate_counter)

    {:ok, timer} = :timer.send_interval(interval, :run)

    state = %{func: func, interval: interval, timer: timer, rate_counter: rate_counter}

    {:ok, state}
  end

  @impl true
  def handle_info(:run, state) do
    state.func.()
    :ok = RateCounter.inc(state.rate_counter)

    {:noreply, state}
  end
end
