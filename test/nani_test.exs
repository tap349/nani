defmodule NaniTest do
  use ExUnit.Case
  doctest Nani

  test "greets the world" do
    assert Nani.hello() == :world
  end
end
