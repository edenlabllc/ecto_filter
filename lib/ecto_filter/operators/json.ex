defmodule EctoFilter.Operators.JSON do
  @moduledoc false

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

      defp prepare_map_conditions(_, _), do: raise("Only :equal condition on JSON fields allowed")
    end
  end
end
