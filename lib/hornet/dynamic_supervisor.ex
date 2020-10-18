defmodule Hornet.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @spec start_link() :: Supervisor.on_start()
  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [])
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
