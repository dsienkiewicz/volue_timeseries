defmodule VoluetsCalculator.Metrics.Metric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "metrics" do
    field :name, :string
    field :t, :naive_datetime
    field :v, :decimal
  end

  @doc false
  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:name, :t, :v])
    |> validate_required([:name, :t, :v])
    |> validate_length(:name, min: 1)
    |> unique_constraint([:name, :t])
  end
end
