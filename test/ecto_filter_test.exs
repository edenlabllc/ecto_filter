defmodule EctoFilterTest do
  use EctoFilter.DataCase

  doctest EctoFilter
  doctest EctoFilter.Operators.Association
  doctest EctoFilter.Operators.Comparison
  doctest EctoFilter.Operators.JSON
  doctest EctoFilter.Operators.Inclusion
  doctest EctoFilter.Operators.PatternMatching
end
