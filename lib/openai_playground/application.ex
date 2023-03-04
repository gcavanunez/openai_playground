defmodule OpenaiPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      OpenaiPlaygroundWeb.Telemetry,
      # Start the Ecto repository
      OpenaiPlayground.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: OpenaiPlayground.PubSub},
      # Start Finch
      {Finch, name: OpenaiPlayground.Finch},
      # Start the Endpoint (http/https)
      OpenaiPlaygroundWeb.Endpoint
      # Start a worker by calling: OpenaiPlayground.Worker.start_link(arg)
      # {OpenaiPlayground.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpenaiPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OpenaiPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
