defmodule EctoFilter.Operators.Association do
  defmacro __using__(_) do
    quote do
      def apply(query, {field, nil, conditions}, %{cardinality: :one, related: context}, _) do
        query
        |> join(:inner, [r], assoc(r, ^field))
        |> filter(conditions, context)
      end
    end
  end
end
