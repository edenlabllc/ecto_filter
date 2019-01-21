defmodule EctoFilter.Contains.JSON do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def apply(query, {field, :contains, value}, {:array, _}, _) do
        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^value))
      end

      def apply(query, {field, nil, conditions}, {:array, :map}) when is_list(conditions) do
        conditions =
          conditions
          |> prepare_conditions()
          |> Map.new()
          |> List.wrap()

        where(query, [..., r], fragment("? @> ?", field(r, ^field), ^conditions))
      end

      defp prepare_conditions([]), do: []

      defp prepare_conditions([{field, :equal, value} | tail]), do: [{field, value} | prepare_conditions(tail)]

      defp prepare_conditions(_), do: raise "Only :equal condition on JSON fields allowed"
    end
  end
end
