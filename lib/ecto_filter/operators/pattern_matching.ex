defmodule EctoFilter.Operators.PatternMatching do
  @moduledoc false

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
