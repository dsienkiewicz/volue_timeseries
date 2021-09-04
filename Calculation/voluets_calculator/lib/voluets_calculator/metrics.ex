defmodule VoluetsCalculator.Metrics do
  @moduledoc """
  The Metrics context.
  """

  import Ecto.Query, warn: false
  alias VoluetsCalculator.Repo

  alias VoluetsCalculator.Metrics.{Metric, Query}

  @doc """
  Returns the list of metrics.
  
  ## Examples
  
      iex> list_metrics()
      [%Metric{}, ...]
  
  """
  def list_metrics do
    Repo.all(Metric)
  end

  def list_metrics_by_stamp(filters) do
    filters = key_to_atom(filters)

    name = filters.name
    from = filters.from
    to = filters.to

    query = Query.aggregate_for_name(name, {from, to})
    result = Repo.one(query)

    case result do
      %{avg: nil, sum: nil} -> %{avg: 0.0, sum: 0.0}
      value -> value
    end
  end

  @doc """
  Creates a metric.
  
  ## Examples
  
      iex> create_metric(%{field: value})
      {:ok, %Metric{}}
  
      iex> create_metric(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_metric(attrs \\ %{}) do
    %Metric{}
    |> Metric.changeset(attrs)
    |> Repo.insert()
  end

  def create_metrics_batch(batch \\ [%{}], batch_size \\ 100) do
    result =
      batch
      |> Stream.chunk_every(batch_size)
      |> Task.async_stream(fn chunk ->
        insert_batch(chunk)
      end)
      |> Stream.map(fn {:ok, {:ok, result}} ->
        processed_no =
          result
          |> Map.values()
          |> Enum.map(fn {count, nil} -> count end)
          |> Enum.sum()

        {:ok, processed_no}
      end)
      |> Enum.to_list()

    {:ok, result}
  end

  defp insert_batch(metrics) do
    multi = Ecto.Multi.new()

    metrics
    |> Enum.map(&key_to_atom(&1))
    |> Enum.map(&convert(&1))
    |> append_changeset_to_multi(multi)
    |> Repo.transaction()
  end

  defp key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_atom(key), value)
    end)
  end

  defp convert(attrs) do
    case Map.get(attrs, :t) do
      %NaiveDateTime{} -> attrs
      value -> %{attrs | t: NaiveDateTime.from_iso8601!(value)}
    end
  end

  defp append_changeset_to_multi([%{} | _] = metrics, multi) do
    changeset_name = "#{inspect(NaiveDateTime.local_now())}"

    multi
    |> Ecto.Multi.insert_all(changeset_name, Metric, metrics)
  end

  defp append_changeset_to_multi([], multi) do
    multi
  end
end
