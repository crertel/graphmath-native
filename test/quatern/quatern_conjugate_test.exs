defmodule GraphmathTest.Quatern.Conjugate do
  use ExUnit.Case, async: false

  @tag :quatern
  @tag :conjugate
  test "conjugate({5,6,7,8}) returns {5,-6,-7,-8}" do
    assert {5, -6, -7, -8} == Graphmath.Quatern.conjugate({5, 6, 7, 8})
  end
end
