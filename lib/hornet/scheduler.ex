defmodule Hornet.Scheduler do
  use GenServer

  alias Hornet.DynamicSupervisor, as: HornetDynamicSupervisor
  alias Hornet.RateCounter
  alias Hornet.Worker.WorkerSupervisor

  @start_period 100
  @period_step 50
  @adjust_period 5_000
  @error_rate 0.1
  @timeout 20_000
  @rate_check 1_000

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: Keyword.fetch!(params, :id))
  end

  def state(name) do
    GenServer.call(name, :state, @timeout)
  end

  def stop(name) do
    :ok = GenServer.call(name, :stop, @timeout)

    pid = Process.whereis(name)
    true = Process.exit(pid, :kill)

    :ok
  end

  @impl true
  def init(params) do
    rate_period = params[:rate_period] || @rate_check

    {:ok, supervisor} = HornetDynamicSupervisor.start_link()

    {:ok, rate_counter} =
      DynamicSupervisor.start_child(supervisor, %{
        id: RateCounter,
        start: {RateCounter, :start_link, [[interval: rate_period]]}
      })

    rate = Keyword.fetch!(params, :rate)
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)
    worker_params = [rate: rate, id: id, func: func]

    period = params[:start_period] || @start_period
    period_step = params[:adjust_step] || @period_step
    adjust_period = params[:adjust_period] || @adjust_period
    error_rate = params[:error_rate] || @error_rate
    process_number_limit = params[:process_number_limit]

    {pid, workers_count} = start_workers(supervisor, worker_params, rate_counter, period)

    {:ok, timer} = :timer.send_interval(adjust_period, :adjust_workers)

    state = %{
      rate_counter: rate_counter,
      worker_supervisor: pid,
      supervisor: supervisor,
      current_workers_count: workers_count,
      period: period,
      period_step: period_step,
      adjust_period: adjust_period,
      error_rate: error_rate,
      params: worker_params,
      process_number_limit: process_number_limit,
      timer: timer
    }

    {:ok, state}
  end

  @impl true
  def handle_info(:adjust_workers, state) do
    cond do
      correct_rate?(state) ->
        {:noreply, state}

      process_number_limit?(state) ->
        {:noreply, state}

      true ->
        adjust_workers(state)
    end
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    :ok = DynamicSupervisor.stop(state.supervisor)

    {:reply, :ok, state}
  end

  defp adjust_workers(state) do
    :ok = DynamicSupervisor.terminate_child(state.supervisor, state.worker_supervisor)
    new_period = state.period + state.period_step

    {pid, workers_count} =
      start_workers(state.supervisor, state.params, state.rate_counter, new_period)

    new_state = %{
      state
      | worker_supervisor: pid,
        current_workers_count: workers_count,
        period: new_period
    }

    {:noreply, new_state}
  end

  defp process_number_limit?(state) do
    {_, new_number} = calculate_workers_number(state.params[:rate], state.period)

    state[:process_number_limit] && state[:process_number_limit] <= new_number
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

  defp start_workers(supervisor, params, rate_counter, period) do
    rate = Keyword.fetch!(params, :rate)
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)

    {interval, initial_workers_number} = calculate_workers_number(rate, period)

    params = [
      rate: rate,
      id: id,
      func: func,
      rate_counter: rate_counter,
      workers_number: initial_workers_number,
      interval: interval
    ]

    {:ok, pid} =
      DynamicSupervisor.start_child(supervisor, %{
        id: :worker_supervisor,
        start: {WorkerSupervisor, :start_link, [params]},
        type: :supervisor
      })

    {pid, initial_workers_number}
  end

  defp calculate_workers_number(rate, period) do
    tps = 1_000 / period

    if rate / tps <= 1 do
      period = round(1000 / rate)

      {period, 1}
    else
      workers = round(rate / tps)

      {period, workers}
    end
  end
end
