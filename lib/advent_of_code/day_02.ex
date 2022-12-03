defmodule AdventOfCode.Day02 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn s -> String.split(s, " ", trim: true) |> map(&String.to_atom/1) end)
  end

  def c([:A, :X]), do: {0, :rock}
  def c([:A, :Y]), do: {2, :paper}
  def c([:A, :Z]), do: {1, :scissors}
  def c([:B, :X]), do: {1, :rock}
  def c([:B, :Y]), do: {0, :paper}
  def c([:B, :Z]), do: {2, :scissors}
  def c([:C, :X]), do: {2, :rock}
  def c([:C, :Y]), do: {1, :paper}
  def c([:C, :Z]), do: {0, :scissors}

  def v(:rock), do: 1
  def v(:paper), do: 2
  def v(:scissors), do: 3

  def score({0, what}), do: 3 + v(what)
  def score({1, what}), do: v(what)
  def score({2, what}), do: 6 + v(what)

  def part1(args) do
    args
    |> parse()
    |> map(fn match -> match |> c() |> score() end)
    |> sum()
  end

  def d([:A, :X]), do: {1, :scissors}
  def d([:A, :Y]), do: {0, :rock}
  def d([:A, :Z]), do: {2, :paper}
  def d([:B, :X]), do: {1, :rock}
  def d([:B, :Y]), do: {0, :paper}
  def d([:B, :Z]), do: {2, :scissors}
  def d([:C, :X]), do: {1, :paper}
  def d([:C, :Y]), do: {0, :scissors}
  def d([:C, :Z]), do: {2, :rock}

  def part2(args) do
    args
    |> parse()
    |> map(fn match -> match |> d() |> score() end)
    |> sum()
  end
end
