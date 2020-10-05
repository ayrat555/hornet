defmodule Hornet.Worker.WorkerSupervisor do
  use Supervisor

  alias Hornet.Worker

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(params) do
    id = Keyword.fetch!(params, :id)
    func = Keyword.fetch!(params, :func)
    rate_counter = Keyword.fetch!(params, :rate_counter)
    workers_number = Keyword.fetch!(params, :workers_number)
    interval = Keyword.fetch!(params, :interval)

    children =
      Enum.map(1..workers_number, fn idx ->
        %{
          id: {id, idx},
          start:
            {Worker, :start_link, [[interval: interval, func: func, rate_counter: rate_counter]]}
        }
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
