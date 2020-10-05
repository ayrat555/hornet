defmodule Hornet.Scheduler do
  use GenServer

  alias Hornet.RateCounter
  alias Hornet.Worker

  @start_period 100
  @period_step 50
  @adjust_period 5_000
  @error_rate 0.1

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: Keyword.fetch!(params, :id))
  end

  def state(name) do
    GenServer.call(name, :state)
  end

  @impl true
  def init(params) do
    {:ok, rate_counter} = RateCounter.start_link()

    rate = Keyword.fetch!(params, :rate)
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)
    worker_params = [rate: rate, id: id, func: func]

    period = params[:start_period] || @start_period
    period_step = params[:adjust_step] || @period_step
    adjust_period = params[:adjust_period] || @adjust_period
    error_rate = params[:error_rate] || @error_rate

    {pid, workers_count} = start_workers(worker_params, rate_counter, period)

    {:ok, timer} = :timer.send_interval(adjust_period, :adjust_workers)

    state = %{
      rate_counter: rate_counter,
      supervisor: pid,
      current_workers_count: workers_count,
      period: period,
      period_step: period_step,
      adjust_period: adjust_period,
      error_rate: error_rate,
      params: worker_params,
      timer: timer
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:adjust_workers, state) do
    if correct_rate?(state) do
      {:noreply, state}
    else
      :ok = Supervisor.stop(state.supervisor)
      new_period = state.period + state.period_step

      {pid, workers_count} = start_workers(state.params, state.rate_counter, new_period)

      new_state = %{
        state
        | supervisor: pid,
          current_workers_count: workers_count,
          period: new_period
      }

      {:noreply, new_state}
    end
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  defp correct_rate?(state) do
    current_rate = RateCounter.rate(state.rate_counter)
    expected_rate = state.params[:rate]
    error_rate = expected_rate * state.error_rate

    if current_rate > expected_rate do
      current_rate - expected_rate < error_rate
    else
      expected_rate - current_rate < error_rate
    end
  end

  defp start_workers(params, rate_counter, period) do
    rate = Keyword.fetch!(params, :rate)
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)

    {interval, initial_workers_number} = calculate_workers_number(rate, period)

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

  defp calculate_workers_number(rate, period) do
    tps = 1_000 / period

    if rate / tps < 1 do
      period = round(1000 / rate)

      {period, 1}
    else
      workers = round(rate / tps)

      {period, workers}
    end
  end
end
