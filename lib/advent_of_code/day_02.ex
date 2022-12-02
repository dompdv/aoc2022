defmodule AdventOfCode.Day02 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&to_charlist/1)
  end

  def c([?A, 32, ?X]), do: {0, :rock, :rock}
  def c([?A, 32, ?Y]), do: {2, :rock, :paper}
  def c([?A, 32, ?Z]), do: {1, :rock, :scissors}
  def c([?B, 32, ?X]), do: {1, :paper, :rock}
  def c([?B, 32, ?Y]), do: {0, :paper, :paper}
  def c([?B, 32, ?Z]), do: {2, :paper, :scissors}
  def c([?C, 32, ?X]), do: {2, :scissors, :rock}
  def c([?C, 32, ?Y]), do: {1, :scissors, :paper}
  def c([?C, 32, ?Z]), do: {0, :scissors, :scissors}

  def v(:rock), do: 1
  def v(:paper), do: 2
  def v(:scissors), do: 3

  def part1(args) do
    args
    |> parse()
    |> map(fn match ->
      {winner, _, what} = c(match)

      case winner do
        0 -> 3
        1 -> 0
        2 -> 6
      end + v(what)
    end)
    |> sum()
  end

  def d([?A, 32, ?X]), do: {1, :scissors}
  def d([?A, 32, ?Y]), do: {0, :rock}
  def d([?A, 32, ?Z]), do: {2, :paper}
  def d([?B, 32, ?X]), do: {1, :rock}
  def d([?B, 32, ?Y]), do: {0, :paper}
  def d([?B, 32, ?Z]), do: {2, :scissors}
  def d([?C, 32, ?X]), do: {1, :paper}
  def d([?C, 32, ?Y]), do: {0, :scissors}
  def d([?C, 32, ?Z]), do: {2, :rock}

  def part2(args) do
    args
    |> parse()
    |> map(fn match ->
      {winner, what} = d(match)

      case winner do
        0 -> 3
        1 -> 0
        2 -> 6
      end + v(what)
    end)
    |> sum()
  end
end
