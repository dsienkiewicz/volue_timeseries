defmodule VoluetsCalculatorWeb.MetricControllerTest do
  use VoluetsCalculatorWeb.ConnCase

  alias VoluetsCalculator.Metrics
  alias VoluetsCalculator.Metrics.Metric

  @create_attrs %{
    name: "some name",
    t: ~N[1970-06-06 10:19:11],
    v: 120.5
  }
  @update_attrs %{
    name: "some updated name",
    t: ~N[1970-06-06 10:19:12],
    v: 456.7
  }
  @invalid_attrs %{name: nil, t: nil, v: nil}

  def fixture(:metric) do
    {:ok, metric} = Metrics.create_metric(@create_attrs)
    metric
  end

  def epoch_to_naive(epoch) do
    epoch
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show" do
    test "lists filtered metrics", %{conn: conn} do
      [
        %{name: "some name", t: ~N[1970-06-05 23:14:11], v: 150.9},
        %{name: "some name", t: ~N[1970-06-06 10:19:11], v: 120.5},
        %{name: "some name", t: ~N[1970-06-06 22:34:11], v: 150.9},
        %{name: "some name", t: ~N[1970-06-07 10:19:11], v: 113.8}
      ]
      |> Enum.each(&Metrics.create_metric(&1))

      filters = %{
        from: ~N[1970-06-06 00:00:00],
        to: ~N[1970-06-06 23:59:59]
      }

      conn = get(conn, Routes.metric_path(conn, :show, "some name"), filters)

      assert json_response(conn, 200) == %{
               "avg" => "135.7000000000000000",
               "sum" => "271.4"
             }
    end
  end

  describe "create batch of metrics" do
    test "renders metrics when data is valid", %{conn: conn} do
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

      conn = post(conn, Routes.metric_path(conn, :create), _json: sample_attrs)
      assert response(conn, 201)
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, Routes.metric_path(conn, :create), metrics: [@invalid_attrs])
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  defp create_metric(_) do
    metric = fixture(:metric)
    %{metric: metric}
  end
end
