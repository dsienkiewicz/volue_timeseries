defmodule VoluetsCalculatorWeb.MetricController do
  use VoluetsCalculatorWeb, :controller

  alias VoluetsCalculator.Metrics

  action_fallback VoluetsCalculatorWeb.FallbackController

  def show(conn, %{"id" => name, "from" => from, "to" => to}) do
    metrics = Metrics.list_metrics_by_stamp(%{name: name, from: from, to: to})
    render(conn, "aggregate.json", metrics: metrics)
  end

  def create(conn, %{"_json" => metrics_params}) do
    with {:ok, _} <- Metrics.create_metrics_batch(metrics_params) do
      conn
      |> send_resp(:created, "")
    end
  end
end
