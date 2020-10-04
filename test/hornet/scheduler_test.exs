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
  end

  test "starts many workers" do
    func = fn ->
      :ok
    end

    params = [id: :test1, func: func, rate: 100_000]

    {:ok, _pid} = Scheduler.start_link(params)

    Process.sleep(5_000)

    state = Scheduler.state(params[:id])
    rate = RateCounter.rate(state.rate_counter)

    assert_rates(params[:rate], rate)

    assert 10_000 == state.current_workers_count
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
