defmodule Hornet.SchedulerTest do
  use ExUnit.Case

  alias Hornet.Scheduler
  alias Hornet.RateCounter

  test "starts workers which maintain rate with one worker" do
    func = fn ->
      :ok
    end

    params = [id: :test, func: func, rate: 5]

    {:ok, _pid} = Scheduler.start_link(params)

    Process.sleep(5_000)

    state = Scheduler.state(params[:id])
    rate = RateCounter.rate(state.rate_counter)

    assert params[:rate] == rate

    :ok = Scheduler.stop(params[:id])
  end

  test "starts workers which maintain rate with multiple workers" do
    func = fn ->
      :ok
    end

    params = [id: :test1, func: func, rate: 1_000]

    {:ok, _pid} = Scheduler.start_link(params)

    Process.sleep(5_000)

    state = Scheduler.state(params[:id])
    rate = RateCounter.rate(state.rate_counter)

    assert params[:rate] == rate
    assert 100 == state.current_workers_count

    :ok = Scheduler.stop(params[:id])
  end

  test "starts many workers" do
    func = fn ->
      :ok
    end

    params = [id: :test2, func: func, rate: 100_000]

    {:ok, _pid} = Scheduler.start_link(params)

    Process.sleep(5_000)

    state = Scheduler.state(params[:id])
    rate = RateCounter.rate(state.rate_counter)

    assert_rates(params[:rate], rate)

    assert 10_000 == state.current_workers_count

    :ok = Scheduler.stop(params[:id])
  end

  test "adjusts period" do
    func = fn ->
      Process.sleep(250)
    end

    params = [id: :test3, func: func, rate: 5]

    {:ok, _pid} = Scheduler.start_link(params)

    state = Scheduler.state(params[:id])

    assert state.current_workers_count == 1
    assert state.period == 100

    Process.sleep(6_000)

    new_state = Scheduler.state(params[:id])

    assert new_state.current_workers_count == 1
    assert new_state.period == 150

    :ok = Scheduler.stop(params[:id])
  end

  test "adjust the number of workers" do
    func = fn ->
      Process.sleep(500)
    end

    params = [
      id: :test4,
      func: func,
      rate: 2,
      adjust_period: 2_000,
      adjust_step: 200,
      start_period: 600
    ]

    {:ok, _pid} = Scheduler.start_link(params)

    state = Scheduler.state(params[:id])

    assert state.current_workers_count == 1
    assert state.period == 600

    Process.sleep(10_000)

    new_state = Scheduler.state(params[:id])

    assert new_state.current_workers_count == 2

    rate = RateCounter.rate(state.rate_counter)

    assert params[:rate] == rate

    :ok = Scheduler.stop(params[:id])
  end

  test "does not adjust the number of workers if process number limit is set" do
    func = fn ->
      Process.sleep(400)
    end

    params = [
      id: :test4,
      func: func,
      rate: 4,
      adjust_period: 3_000,
      adjust_step: 300,
      start_period: 100,
      process_number_limit: 1
    ]

    {:ok, _pid} = Scheduler.start_link(params)

    state = Scheduler.state(params[:id])

    assert state.current_workers_count == 1
    assert state.period == 100

    Process.sleep(10_000)

    new_state = Scheduler.state(params[:id])

    assert new_state.current_workers_count == 1
    assert new_state.period == 100

    :ok = Scheduler.stop(params[:id])
  end

  test "stops scheduler and all child processes" do
    func = fn ->
      :ok
    end

    params = [id: :test5, func: func, rate: 5]

    {:ok, _pid} = Scheduler.start_link(params)

    state = Scheduler.state(params[:id])
    Scheduler.stop(params[:id])

    refute Process.alive?(state.supervisor)
    refute Process.alive?(state.rate_counter)
    refute Process.alive?(state.worker_supervisor)
  end

  defp assert_rates(expected, actual, percentage \\ 0.1) do
    error_rate = expected * percentage

    if expected > actual do
      assert expected - actual < error_rate
    else
      assert actual - expected < error_rate
    end
  end
end
