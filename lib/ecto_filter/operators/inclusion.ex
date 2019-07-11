defmodule EctoFilter.Operators.Inclusion do
  @moduledoc """
  Inclusion operators.

  ## Examples:

      iex> Repo.insert!(%Post{category: "News"})
      iex> Repo.insert!(%Post{category: "Sports"})
      iex> result =
      ...>   Post
      ...>   |> EctoFilter.filter([{:category, :in, ["News", "Weather"]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).category
      "News"

      iex> Repo.insert!(%Post{tags: ["News", "Sports"]})
      iex> Repo.insert!(%Post{tags: ["Weather"]})
      iex> result =
      ...>   Post
      ...>   |> EctoFilter.filter([{:tags, :contains, "Sports"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).tags
      ["News", "Sports"]

  """

  @type rule() :: :in | :contains

  @type condition :: {field :: atom, rule :: rule(), value :: any}

  @callback apply(
              query :: Ecto.Query.t(),
              condition :: condition(),
              type :: EctoFilter.field_type(),
              context :: Ecto.Queriable.t()
            ) :: Ecto.Query.t()

  @doc false
  defmacro __using__(_) do
    quote do
      def apply(query, {field, :in, value}, _, _) when is_list(value) do
        where(query, [..., r], field(r, ^field) in ^value)
      end

      def apply(query, {field, :contains, value}, {:array, _}, _) do
        where(query, [..., r], ^value in field(r, ^field))
      end
    end
  end
end
