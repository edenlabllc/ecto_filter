defmodule EctoFilter.Operators.Comparison do
  @moduledoc """
  Comparison operators.

  ## Examples:

  #### With "equal" condition

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: "alice@example.com"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :equal, "alice@example.com"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).email
      "alice@example.com"

  Comparison with `nil` are supported:

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: nil})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :equal, nil}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).email
      nil

  #### With "not equal" condition

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: "alice@example.com"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :not_equal, "alice@example.com"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).email
      "bob@example.com"

  Comparison with `nil` are also supported:

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: nil})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :not_equal, nil}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).email
      "bob@example.com"

  #### With "equal_one_of" condition

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: "alice@example.com"})
      iex> Repo.insert!(%User{email: "eve@example.com"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :equal_one_of, ["alice@example.com", "bob@example.com"]}])
      ...>   |> Repo.all()
      iex> length(result)
      2
      iex> Enum.map(result, fn user -> user.email end)
      ["bob@example.com", "alice@example.com"]

  #### With "less than or equal" condition

      iex> Repo.insert!(%User{age: 17})
      iex> Repo.insert!(%User{age: 18})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:age, :less_than_or_equal, 17}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).age
      17

  #### With "greater than or equal" condition

      iex> Repo.insert!(%User{age: 17})
      iex> Repo.insert!(%User{age: 18})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:age, :greater_than_or_equal, 18}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).age
      18

  #### With "less than" condition

      iex> Repo.insert!(%User{age: 17})
      iex> Repo.insert!(%User{age: 21})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:age, :less_than, 20}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).age
      17

  #### With "greater than" condition

      iex> Repo.insert!(%User{age: 17})
      iex> Repo.insert!(%User{age: 21})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:age, :greater_than, 18}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).age
      21

  """

  @type rule() ::
          :equal
          | :not_equal
          | :equal_one_of
          | :less_than_or_equal
          | :greater_than_or_equal
          | :less_than
          | :greater_than

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
      def apply(query, {field, :equal, nil}, _, _) do
        where(query, [..., r], is_nil(field(r, ^field)))
      end

      def apply(query, {field, :equal, value}, _, _) do
        where(query, [..., r], field(r, ^field) == ^value)
      end

      def apply(query, {field, :equal_one_of, values}, _, _) do
        where(query, [..., r], field(r, ^field) in ^values)
      end

      def apply(query, {field, :not_equal, nil}, _, _) do
        where(query, [..., r], not is_nil(field(r, ^field)))
      end

      def apply(query, {field, :not_equal, value}, _, _) do
        where(query, [..., r], field(r, ^field) != ^value)
      end

      def apply(query, {field, :less_than_or_equal, value}, _, _) do
        where(query, [..., r], field(r, ^field) <= ^value)
      end

      def apply(query, {field, :greater_than_or_equal, value}, _, _) do
        where(query, [..., r], field(r, ^field) >= ^value)
      end

      def apply(query, {field, :less_than, value}, _, _) do
        where(query, [..., r], field(r, ^field) < ^value)
      end

      def apply(query, {field, :greater_than, value}, _, _) do
        where(query, [..., r], field(r, ^field) > ^value)
      end
    end
  end
end
