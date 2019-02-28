defmodule EctoFilter.Operators.PatternMatching do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      def apply(query, {field, :like, value}, _, _) do
        value = String.replace(value, "%", "\\%")
        
        where(query, [..., r], ilike(field(r, ^field), ^"%#{value}%"))
      end
    end
  end
end
