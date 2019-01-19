defmodule EctoFilter.DataCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using _ do
    quote do
      alias EctoFilter.{Organization, Post, Repo, User}

      import EctoFilter.Factory
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EctoFilter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EctoFilter.Repo, {:shared, self()})
    end

    :ok
  end
end
