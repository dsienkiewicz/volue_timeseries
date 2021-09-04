defmodule VoluetsCalculator.Metrics.Query do
  import Ecto.Query

  alias VoluetsCalculator.Metrics.Metric

  def aggregate_for_name(name, {from, to}) do
    query =
      from m in Metric,
        where: m.name == ^name and m.t >= ^from and m.t <= ^to,
        select: %{avg: avg(m.v), sum: sum(m.v)}

    query
  end
end
