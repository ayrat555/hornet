defmodule Hornet.Worker do
  @moduledoc false

  use GenServer

  alias Hornet.RateCounter

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl true
  def init(params) do
    func = Keyword.fetch!(params, :func)
    interval = Keyword.fetch!(params, :interval)
    rate_counter = Keyword.fetch!(params, :rate_counter)

    if interval > 10_000 do
      Process.send_after(self(), :run, 500)
    end

    Process.send_after(self(), :run_and_schedule, interval)

    state = %{func: func, interval: interval, rate_counter: rate_counter}
    {:ok, state}
  end

  @impl true
  def handle_info(:run, state) do
    execute(state)

    {:noreply, state}
  end

  @impl true
  def handle_info(:run_and_schedule, state) do
    execute_and_schedule(state)

    {:noreply, state}
  end

  defp execute(state) do
    state.func.()
    :ok = RateCounter.inc(state.rate_counter)
  end

  defp execute_and_schedule(state) do
    execute(state)

    Process.send_after(self(), :run_and_schedule, state.interval)
  end
end
