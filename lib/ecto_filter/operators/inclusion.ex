defmodule EctoFilter.Operators.Inclusion do
  @moduledoc false

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
