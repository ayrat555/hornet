defmodule Hornet.RateCounter do
  use GenServer

  @interval 1_000

  def start_link(params \\ []) do
    GenServer.start_link(__MODULE__, params)
  end

  def inc(pid) do
    GenServer.cast(pid, :inc)
  end

  def rate(pid) do
    GenServer.call(pid, :rate)
  end

  @impl true
  def init(params) do
    interval = params[:interval] || @interval
    {:ok, timer} = :timer.send_interval(interval, :calculate_rate)

    state = %{rate: 0, count: 0, timer: timer, interval: interval}

    {:ok, state}
  end

  @impl true
  def handle_info(:calculate_rate, state) do
    rate = round(state.count / state.interval * 1000)
    new_state = %{rate: rate, count: 0, timer: state.timer, interval: state.interval}

    {:noreply, new_state}
  end

  @impl true
  def handle_cast(:inc, state) do
    new_state = %{state | count: state.count + 1}

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:rate, _from, state) do
    {:reply, state.rate, state}
  end
end
