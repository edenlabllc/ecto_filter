defmodule EctoFilter.Operators do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use EctoFilter.Operators.{
        Association,
        Comparison,
        Inclusion,
        PatternMatching
      }
    end
  end
end
