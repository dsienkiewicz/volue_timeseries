defmodule VoluetsCalculator.Release do
  @app :voluets_calculator

  def createdb do
    Enum.each(repos(), fn repo ->
      repo.__adapter__.storage_up(repo.config)
    end)
  end

  @doc """
    Run Ecto migrator task to execute all Db `:up` automatic migrations
  """
  def migrate do
    for repo <- repos() do
      path = Ecto.Migrator.migrations_path(repo)
      run_migrations(repo, path)
    end
  end

  @doc """
    Run Ecto migrator task to execute all Db `:up` manual migrations
  """
  def migrate_manual do
    for repo <- repos() do
      path = Ecto.Migrator.migrations_path(repo, "manual_migrations")
      run_migrations(repo, path)
    end
  end

  @doc """
    Run Ecto migrator task to execute all Db `:down` to `version` migrations
  """
  def rollback(version) do
    for repo <- repos() do
      path = Ecto.Migrator.migrations_path(repo, "manual_migrations")
      rollback_migrations(repo, path, version)
    end
  end

  defp run_migrations(repo, path) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :up, all: true))
  end

  defp rollback_migrations(repo, path, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, path, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end
end
