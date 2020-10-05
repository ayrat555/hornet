defmodule Hornet.RateCounterTest do
  use ExUnit.Case

  alias Hornet.RateCounter

  test "correctly calculates rates" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 1_000)

    assert RateCounter.rate(pid) == 1_000
  end

  test "re-calculates rate" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 10)

    assert RateCounter.rate(pid) == 10

    inc(pid, 20)

    assert RateCounter.rate(pid) == 20
  end

  test "can handle 10_000 rate" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 10_000)

    assert RateCounter.rate(pid) == 10_000
  end

  test "can handle 100_000 rate" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 100_000)

    assert RateCounter.rate(pid) == 100_000
  end

  test "can handle 1_000_000 rate" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 1_000_000)

    assert RateCounter.rate(pid) == 1_000_000
  end

  test "can handle 2_000_000 rate" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 2_000_000)

    assert RateCounter.rate(pid) == 2_000_000
  end

  test "re-calculates large rates" do
    {:ok, pid} = RateCounter.start_link()

    inc(pid, 400_000)

    assert RateCounter.rate(pid) == 400_000

    inc(pid, 500_000)

    assert RateCounter.rate(pid) == 500_000
  end

  test "calculate average rate for 2 seconds" do
    {:ok, pid} = RateCounter.start_link(interval: 2_000)

    inc(pid, 60, 2_000)

    assert RateCounter.rate(pid) == 30
  end

  defp inc(pid, count, timeout \\ 1_000) do
    func = fn -> Enum.each(1..count, fn _ -> RateCounter.inc(pid) end) end

    execution_time =
      func
      |> :timer.tc()
      |> elem(0)
      |> Kernel./(1_000)

    if execution_time > 1_000 do
      raise RuntimeError, message: "executed more that 1 s"
    end

    Process.sleep(round(timeout + 100 - execution_time))
  end
end
