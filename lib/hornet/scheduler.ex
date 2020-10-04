defmodule Hornet.Scheduler do
  use GenServer

  alias Hornet.RateCounter
  alias Hornet.Worker

  @min_period 100
  @adjust_period 5_000

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: Keyword.fetch!(params, :id))
  end

  def state(name) do
    GenServer.call(name, :state)
  end

  @impl true
  def init(params) do
    {:ok, rate_counter} = RateCounter.start_link()

    {pid, workers_count} = start_workers(params, rate_counter)

    {:ok, timer} = :timer.send_interval(@adjust_period, :adjust_workers)

    state = %{
      rate_counter: rate_counter,
      params: params,
      supervisor: pid,
      current_workers_count: workers_count,
      timer: timer
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:adjust_workers, state) do
    # TODO
    {:noreply, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp start_workers(params, rate_counter) do
    rate = Keyword.fetch!(params, :rate)
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)

    {interval, initial_workers_number} = calculate_initial_workers_number(rate)

    workers =
      Enum.map(1..initial_workers_number, fn idx ->
        %{
          id: {id, idx},
          start:
            {Worker, :start_link, [[interval: interval, func: func, rate_counter: rate_counter]]}
        }
      end)

    {:ok, pid} = Supervisor.start_link(workers, strategy: :one_for_one)

    {pid, initial_workers_number}
  end

  defp calculate_initial_workers_number(rate) do
    if rate / @min_period < 1 do
      period = round(1000 / rate)

      {period, 1}
    else
      workers = round(rate / @min_period)

      {@min_period, workers * 10}
    end
  end
end
