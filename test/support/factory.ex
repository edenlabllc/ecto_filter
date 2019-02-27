defmodule EctoFilter.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: EctoFilter.Repo

  alias EctoFilter.{Comment, Organization, Post, User}

  def comment_factory do
    %Comment{
      body: "Dolor sit amet, consectetur adipiscing elit",
      author: build(:user),
      post: build(:post)
    }
  end

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
      age: 20
    }
  end
end
