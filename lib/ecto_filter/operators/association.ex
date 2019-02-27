defmodule EctoFilter.Operators.Association do
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

      def apply(query, {field, nil, conditions}, %{cardinality: :many, owner_key: owner_key, through: through} = type, context) do
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
