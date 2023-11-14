defmodule AonChat.Repo do
  use Ecto.Repo,
    otp_app: :aon_chat,
    adapter: Ecto.Adapters.Postgres
end
