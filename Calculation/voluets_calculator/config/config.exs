# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :voluets_calculator,
  ecto_repos: [VoluetsCalculator.Repo]

# Configures the endpoint
config :voluets_calculator, VoluetsCalculatorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "af9Q2YepJ6MJtFsSvf8szlOdzu0dJicxg+A4sH8gwb6LB1leleFePoL41+wXSgZ+",
  render_errors: [view: VoluetsCalculatorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: VoluetsCalculator.PubSub,
  live_view: [signing_salt: "gs0ptDQ6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix, :format_encoders, json: ProperCase.JSONEncoder.CamelCase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
