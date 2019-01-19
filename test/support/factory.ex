defmodule EctoFilter.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: EctoFilter.Repo

  alias EctoFilter.{Organization, Post, User}

  def organization_factory do
    %Organization{
      name: "Acme Corporation"
    }
  end

  def post_factory do
    %Post{
      title: "Lorem Ipsum",
      body: "Dolor sit amet, consectetur adipiscing elit",
      tags: ~w(lorem ipsum),
      author: build(:user)
    }
  end

  def user_factory do
    %User{
      first_name: "John",
      last_name: "Doe",
      email: "john@doe.com",
      age: 20,
      organization: build(:organization)
    }
  end
end
