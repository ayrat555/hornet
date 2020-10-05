defmodule Hornet.WorkerTest do
  use ExUnit.Case

  alias Hornet.RateCounter
  alias Hornet.Worker

  test "executes a function by intervals" do
    test_pid = self()

    func = fn ->
      val =
        case :ets.whereis(:foo) do
          :undefined ->
            val = 1
            :ets.new(:foo, [:set, :protected, :named_table])
            :ets.insert(:foo, {"foo", val})
            val

          _ ->
            [{"foo", val}] = :ets.lookup(:foo, "foo")
            :ets.insert(:foo, {"foo", val + 1})
            val + 1
        end

      send(test_pid, {:hello, val})
    end

    {:ok, pid} = RateCounter.start_link()

    Worker.start_link(func: func, interval: 100, rate_counter: pid)

    assert_receive {:hello, 1}, 1000
    assert_receive {:hello, 2}, 1000
    assert_receive {:hello, 3}, 1000
    assert_receive {:hello, 4}, 1000
    assert_receive {:hello, 5}, 1000

    Process.sleep(3_000)

    assert RateCounter.rate(pid) == 10
  end

  test "executes func immediately if interval is too long" do
    test_pid = self()

    func = fn ->
      send(test_pid, :hello)
    end

    {:ok, pid} = RateCounter.start_link()

    Worker.start_link(func: func, interval: 100, rate_counter: pid)

    assert_receive :hello, 1000
  end
end
