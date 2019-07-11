defmodule EctoFilter.Operators.PatternMatching do
  @moduledoc """
  Pattern matching operators.

  ## Examples:

  #### With "LIKE" condition

      iex> Repo.insert!(%User{first_name: "Bob"})
      iex> Repo.insert!(%User{first_name: "Alice"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:first_name, :like, "al"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Alice"

  """

  @type rule() :: :like

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
      def apply(query, {field, :like, value}, _, _) do
        value = sanitize_like_input(value)

        where(query, [..., r], ilike(field(r, ^field), ^"%#{value}%"))
      end

      defp sanitize_like_input(string), do: String.replace(string, "%", "\\%")
    end
  end
end
