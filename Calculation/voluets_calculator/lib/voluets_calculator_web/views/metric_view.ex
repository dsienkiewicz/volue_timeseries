defmodule VoluetsCalculatorWeb.MetricView do
  use VoluetsCalculatorWeb, :view
  alias VoluetsCalculatorWeb.MetricView

  def render("index.json", %{metrics: metrics}) do
    %{data: render_many(metrics, MetricView, "metric.json")}
  end

  def render("aggregate.json", %{metrics: metrics}) do
    %{avg: metrics.avg, sum: metrics.sum}
  end

  def render("show.json", %{metric: metric}) do
    %{data: render_one(metric, MetricView, "metric.json")}
  end

  def render("metric.json", %{metric: metric}) do
    %{id: metric.id, name: metric.name, t: metric.t, v: metric.v}
  end
end
