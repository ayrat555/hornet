defmodule Hornet.ParamsValidator do
  @moduledoc false

  @required_fields [:rate, :id, :func]
  @optional_fields %{
    start_period: 100,
    adjust_step: 50,
    adjust_period: 5_000,
    error_rate: 0.1,
    process_number_limit: nil,
    rate_period: 1_000
  }

  @spec validate!(Keyword.t()) :: Keyword.t()
  def validate!(params) do
    params
    |> clean_params()
    |> set_default_values()
    |> validate_required!()
  end

  defp clean_params(params) do
    all_keys =
      @optional_fields
      |> Map.keys()
      |> Kernel.++(@required_fields)

    Keyword.take(params, all_keys)
  end

  defp set_default_values(params) do
    Enum.reduce(@optional_fields, params, fn {key, value}, acc ->
      Keyword.put_new(acc, key, value)
    end)
  end

  def validate_required!(params) do
    Enum.each(@required_fields, fn field ->
      Keyword.fetch!(params, field)
    end)

    params
  end
end
