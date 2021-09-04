defmodule VoluetsCalculator.Repo do
  use Ecto.Repo,
    otp_app: :voluets_calculator,
    adapter: Ecto.Adapters.Postgres
end
