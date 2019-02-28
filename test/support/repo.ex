defmodule EctoFilter.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :ecto_filter,
    adapter: Ecto.Adapters.Postgres
end
