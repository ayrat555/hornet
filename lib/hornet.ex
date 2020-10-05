defmodule Hornet do
  alias Hornet.Scheduler

  def start(params) do
    Scheduler.start_link(params)
  end

  def stop(name) do
    Scheduler.stop(name)
  end
end
