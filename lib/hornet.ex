defmodule Hornet do
  alias Hornet.Scheduler

  @spec start(Keyword.t()) :: GenServer.on_start()
  def start(params) do
    Scheduler.start_link(params)
  end

  @spec stop(atom() | pid) :: :ok
  def stop(name) do
    Scheduler.stop(name)
  end
end
