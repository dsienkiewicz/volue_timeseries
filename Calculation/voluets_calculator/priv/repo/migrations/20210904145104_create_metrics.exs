defmodule VoluetsCalculator.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics) do
      add :name, :string, null: false
      add :t, :timestamp, null: false
      add :v, :decimal, null: false
    end

    create index(:metrics, [:name, :t], unique: true)
  end
end
