defmodule EctoFilter.Operators.Comparison do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def apply(query, {field, :equal, nil}, _, _) do
        where(query, [..., r], is_nil(field(r, ^field)))
      end

      def apply(query, {field, :equal, value}, _, _) do
        where(query, [..., r], field(r, ^field) == ^value)
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
