defmodule HornetTest do
  use ExUnit.Case
  doctest Hornet

  test "greets the world" do
    assert Hornet.hello() == :world
  end
end
