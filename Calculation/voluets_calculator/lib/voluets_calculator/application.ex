defmodule VoluetsCalculator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias VoluetsCalculator.Release

  def start(_type, _args) do
    Release.migrate()

    children = [
      # Start the Ecto repository
      VoluetsCalculator.Repo,
      # Start the Telemetry supervisor
      VoluetsCalculatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: VoluetsCalculator.PubSub},
      # Start the Endpoint (http/https)
      VoluetsCalculatorWeb.Endpoint
      # Start a worker by calling: VoluetsCalculator.Worker.start_link(arg)
      # {VoluetsCalculator.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VoluetsCalculator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    VoluetsCalculatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
