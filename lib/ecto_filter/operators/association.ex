defmodule EctoFilter.Operators.Association do
  @moduledoc """
  Association operators.

  ## Examples:

  #### With "one" cardinality

      iex> acme_org = Repo.insert!(%Organization{name: "Acme"})
      iex> globex_org = Repo.insert!(%Organization{name: "Globex"})
      iex> Repo.insert!(%User{first_name: "Bob", organization: acme_org})
      iex> Repo.insert!(%User{first_name: "Alice", organization: globex_org})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:organization, nil, [{:name, :like, "acme"}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Bob"

  #### With "many" cardinality

      iex> bob = Repo.insert!(%User{first_name: "Bob"})
      iex> alice = Repo.insert!(%User{first_name: "Alice"})
      iex> Repo.insert!(%Post{title: "Post about weather", author: bob})
      iex> Repo.insert!(%Post{title: "Post about sports", author: alice})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:posts, nil, [{:title, :like, "sports"}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Alice"

  #### With "many" cardinality through another association

      iex> weather_post = Repo.insert!(%Post{title: "Post about weather"})
      iex> sports_post = Repo.insert!(%Post{title: "Post about sports"})
      iex> bob = Repo.insert!(%User{first_name: "Bob"})
      iex> alice = Repo.insert!(%User{first_name: "Alice"})
      iex> Repo.insert!(%Comment{body: "Lorem ipsum", author: bob, post: weather_post})
      iex> Repo.insert!(%Comment{body: "Dolor sit amet", author: alice, post: sports_post})
      iex> result =
      ...>   Post
      ...>   |> EctoFilter.filter([{:comments_authors, nil, [{:first_name, :like, "bob"}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).title
      "Post about weather"

  """

  @type condition :: {field :: atom, nil, conditions :: [EctoFilter.condition()]}

  @callback apply(
              query :: Ecto.Query.t(),
              condition :: condition(),
              type :: Ecto.Association.t(),
              context :: Ecto.Queriable.t()
            ) :: Ecto.Query.t()

  @doc false
  defmacro __using__(_) do
    quote do
      def apply(query, {field, nil, conditions}, %{cardinality: :one, related: related}, _) do
        query
        |> join(:inner, [r], assoc(r, ^field))
        |> filter(conditions, related)
      end

      def apply(query, {field, nil, conditions}, %{cardinality: :many, owner_key: owner_key, related: related}, _) do
        query
        |> join(:inner, [r], assoc(r, ^field))
        |> filter(conditions, related)
        |> group_by(^owner_key)
      end

      def apply(
            query,
            {field, nil, conditions},
            %{cardinality: :many, owner_key: owner_key, through: through} = type,
            context
          ) do
        related = related_through(context, through)

        query
        |> join(:inner, [r], assoc(r, ^field))
        |> filter(conditions, related)
        |> group_by(^owner_key)
      end

      defp related_through(queryable, []), do: queryable

      defp related_through(queryable, [related | tail]) do
        with %{related: related} <- queryable.__schema__(:association, related) do
          related_through(related, tail)
        else
          _ -> nil
        end
      end
    end
  end
end
