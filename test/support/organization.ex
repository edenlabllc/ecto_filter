defmodule EctoFilter.Organization do
  use Ecto.Schema

  schema "organizations" do
    field(:name, :string)

    timestamps()
  end
end
