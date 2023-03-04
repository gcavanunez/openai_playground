defmodule OpenaiPlayground.Repo do
  use Ecto.Repo,
    otp_app: :openai_playground,
    adapter: Ecto.Adapters.SQLite3
end
