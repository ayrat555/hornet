defmodule Hornet do
  @moduledoc """
    Hornet is a simple library for stress testing.

    It executes the given function with the given rate (calls per second) dynamically changing the number of processes to maintain the rate.
  """

  alias Hornet.Scheduler

  @doc """
  Starts an instance of Hornet.

  ## Parameters

    It accepts a keyword list.

    Required parameters:
      - rate - the required rate in operations per seconds. For example, `100` (ops/second)
      - func - the anonymous function that has to be executed. For example, `fn -> 1 + 1 end`
      - id - atom that will be used for Hornet's process names.

    Optional parameters:
      - start_period - every process executes the given function periodically. This is a starting value. The default value is 100 ms.
      - adjust_step - if the given rate can no be maintained (for example, if the function is executed too long), Hornet will start increasing the number of processes and the execution period for each process. The period will start increasing by adjust_step. The default value is 50ms.
      - adjust_period - the number of processes adjusted periodically by adjust_period value. The default value is 5_000 ms.
      - error_rate - allowed rate for different between the expected rate and the actual rate:  |current_rate - expected_rate| < error_rate. The default value is 0.1.
      - process_number_limit - if the given function executes too long  but the required rate is high, Hornet will be spawning processes until indefinitely. This value will limit the number of processes. The default value is nil.
      - rate_period - the period of measuring the current rate. The default value is 1_000 ms.

  ## Examples

      iex> params = [rate: 1, func: fn -> IO.inspect("hello") end, id: :hello]
      iex> Hornet.start(params)
      {:ok, #PID<0.201.0>}
      "hello"
      "hello"
      "hello"
      "hello"
      "hello"
      ...
  """
  @spec start(Keyword.t()) :: GenServer.on_start()
  def start(params) do
    Scheduler.start_link(params)
  end

  @doc """
  Stops an instance of Hornet. It accepts the pid returned by `start/1` or the provided id.

  ## Examples

      iex> Hornet.stop(:hello)
      :ok
  """
  @spec stop(atom() | pid) :: :ok
  def stop(name) do
    Scheduler.stop(name)
  end
end
