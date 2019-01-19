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

      # def apply(query, {:date, field, :in, %Date.Interval{first: %Date{} = first, last: %Date{} = last}}) do
      #   where(query, [..., r], fragment("? <@ daterange(?, ?, '[]')", field(r, ^field), ^first, ^last))
      # end

      # def apply(query, {:date, field, :in, %Date.Interval{first: %Date{} = first}}) do
      #   where(query, [..., r], fragment("? <@ daterange(?, 'infinity', '[)')", field(r, ^field), ^first))
      # end

      # def apply(query, {:date, field, :in, %Date.Interval{last: %Date{} = last}}) do
      #   where(query, [..., r], fragment("? <@ daterange('infinity', ?, '(]')", field(r, ^field), ^last))
      # end

      # def apply(query, {{:array, _}, field, :contains, value}) do
      #   where(query, [..., r], fragment("? @> ?", field(r, ^field), ^value))
      # end
    end
  end
end
