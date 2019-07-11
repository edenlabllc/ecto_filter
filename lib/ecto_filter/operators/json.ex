defmodule EctoFilter.Operators.JSON do
  @moduledoc """
  Operators on PostgreSQL JSON/JSONB fields.

  These operators are not included in `EctoFilter` by default and must be used manually:

      defmodule JSONFilter do
        use EctoFilter
        use EctoFilter.Operators.JSON
      end

  ## Examples:

  #### With arrays

      iex> Repo.insert(%User{first_name: "Bob", interests: ["Art", "Books"]})
      iex> Repo.insert(%User{first_name: "Alice", interests: ["Books", "Comics"]})
      iex> result =
      ...>   User
      ...>   |> JSONFilter.filter([{:interests, :contains, "Art"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Bob"

  #### With maps

      iex> Repo.insert(%User{first_name: "Bob", settings: %{send_newsletter: false}})
      iex> Repo.insert(%User{first_name: "Alice", settings: %{send_newsletter: true}})
      iex> result =
      ...>   User
      ...>   |> JSONFilter.filter([{:settings, nil, [{:send_newsletter, :equal, true}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Alice"

  #### With nested maps

      iex> Repo.insert(%User{first_name: "Bob", settings: %{send_newsletter: %{weekly: true, monthly: false}}})
      iex> Repo.insert(%User{first_name: "Alice", settings: %{send_newsletter: %{weekly: false, monthly: true}}})
      iex> result =
      ...>   User
      ...>   |> JSONFilter.filter([{:settings, nil, [{:send_newsletter, nil, [{:weekly, :equal, true}]}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Bob"

  #### With arrays of maps

      iex> Repo.insert(%User{first_name: "Bob", addresses: [%{city: "Kyiv"}, %{city: "Berlin"}]})
      iex> Repo.insert(%User{first_name: "Alice", addresses: [%{city: "Chicago"}]})
      iex> result =
      ...>   User
      ...>   |> JSONFilter.filter([{:addresses, nil, [{:city, :equal, "Kyiv"}]}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Bob"

  """

  @type condition :: {field :: atom, nil, conditions :: [EctoFilter.condition()]}
  @type field_type :: :map | {:map, Ecto.Type.base()} | {:array, Ecto.Type.base()}

  @callback apply(
              query :: Ecto.Query.t(),
              condition :: condition(),
              type :: field_type(),
              context :: Ecto.Queriable.t()
            ) :: Ecto.Query.t()

  @doc false
  defmacro __using__(_) do
    quote do
      def apply(query, {field, :contains, value}, {:array, _}, _) do
        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^value))
      end

      def apply(query, {field, nil, conditions}, :map, _) when is_list(conditions) do
        conditions = prepare_map_conditions(conditions)

        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^conditions))
      end

      def apply(query, {field, nil, conditions}, {:map, _}, _) when is_list(conditions) do
        conditions = prepare_map_conditions(conditions)

        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^conditions))
      end

      def apply(query, {field, nil, conditions}, {:array, :map}, _) when is_list(conditions) do
        conditions =
          conditions
          |> prepare_map_conditions()
          |> List.wrap()

        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^conditions))
      end

      def apply(query, operation, type, context), do: super(query, operation, type, context)

      defoverridable EctoFilter

      defp prepare_map_conditions(acc \\ [], conditions)

      defp prepare_map_conditions(acc, []), do: Map.new(acc)

      defp prepare_map_conditions(acc, [{field, :equal, value} | tail]) do
        prepare_map_conditions([{field, value} | acc], tail)
      end

      defp prepare_map_conditions(acc, [{field, nil, conditions} | tail]) do
        prepare_map_conditions([{field, prepare_map_conditions(conditions)} | acc], tail)
      end

      defp prepare_map_conditions(_, _), do: raise("Only :equal condition on JSON fields allowed")
    end
  end
end
