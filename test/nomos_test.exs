defmodule EunomoTest do
  use ExUnit.Case
  doctest Eunomo
  doctest Eunomo.Formatter.AlphabeticalAliasSorter
  doctest Eunomo.Formatter.AlphabeticalImportSorter

  test "s" do
    assert true
  end
end
