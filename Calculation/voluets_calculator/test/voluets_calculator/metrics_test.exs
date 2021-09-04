defmodule VoluetsCalculator.MetricsTest do
  use VoluetsCalculator.DataCase

  alias VoluetsCalculator.Metrics

  describe "metrics" do
    alias VoluetsCalculator.Metrics.Metric

    @valid_attrs %{name: "some name", t: ~N[1970-06-06 10:19:11], v: 120.5}
    @update_attrs %{name: "some updated name", t: ~N[1970-06-06 10:19:12], v: 456.7}
    @invalid_attrs %{name: nil, t: nil, v: nil}

    def metric_fixture(attrs \\ %{}) do
      {:ok, metric} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Metrics.create_metric()

      metric
    end

    def epoch_to_naive(epoch) do
      epoch
      |> DateTime.from_unix!()
      |> DateTime.to_naive()
    end

    test "list_metrics/0 returns all metrics" do
      metric = metric_fixture()
      assert Metrics.list_metrics() == [metric]
    end

    test "list_metrics_by_stamp/0 returns all filtered metrics" do
      [
        %{name: "some name", t: ~N[1970-06-05 23:14:11], v: 150.9},
        %{name: "some name", t: ~N[1970-06-06 10:19:11], v: 120.5},
        %{name: "some name", t: ~N[1970-06-06 22:34:11], v: 150.9},
        %{name: "some name", t: ~N[1970-06-07 10:19:11], v: 113.8}
      ]
      |> Enum.each(&Metrics.create_metric(&1))

      filters = %{name: "some name", from: ~N[1970-06-06 00:00:00], to: ~N[1970-06-06 23:59:59]}

      assert Metrics.list_metrics_by_stamp(filters) == %{
               avg: Decimal.new("135.7000000000000000"),
               sum: Decimal.new("271.4")
             }
    end

    test "list_metrics_by_stamp/0 returns empty result" do
      filters = %{name: "some name", from: ~N[1970-06-06 00:00:00], to: ~N[1970-06-06 23:59:59]}

      assert Metrics.list_metrics_by_stamp(filters) == %{
               avg: 0.0,
               sum: 0.0
             }
    end

    test "create_metric/1 with valid data creates a metric" do
      assert {:ok, %Metric{} = metric} = Metrics.create_metric(@valid_attrs)
      assert metric.name == "some name"
      assert metric.t == ~N[1970-06-06 10:19:11]
      assert metric.v == Decimal.new("120.5")
    end

    test "create_metric/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metrics.create_metric(@invalid_attrs)
    end

    test "create_metrics_batch/1 with valid data creates a metrics" do
      sample_attrs =
        13_515_551..(13_515_551 + 999)
        |> Enum.to_list()
        |> Enum.map(
          &%{
            name: "example#{:rand.uniform(2)}",
            t: &1 |> epoch_to_naive,
            v: :rand.uniform(1_000) |> Kernel./(3.0)
          }
        )

      assert {:ok, result} = Metrics.create_metrics_batch(sample_attrs)

      assert result = [
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100,
               ok: 100
             ]
    end
  end
end
