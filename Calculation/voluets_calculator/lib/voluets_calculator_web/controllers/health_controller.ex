defmodule VoluetsCalculatorWeb.HealthController do
  use VoluetsCalculatorWeb, :controller

  action_fallback VoluetsCalculatorWeb.FallbackController

  def index(conn, _params) do
    conn |> send_resp(:ok, "")
  end
end
