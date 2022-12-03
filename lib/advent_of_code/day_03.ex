defmodule AdventOfCode.Day03 do
  import Enum

  def priority(c) when c >= ?a, do: c - ?a + 1
  def priority(c), do: c - ?A + 27

  def intersect([]), do: []
  def intersect([a, b]), do: MapSet.intersection(MapSet.new(a), MapSet.new(b)) |> MapSet.to_list()
  def intersect([a | r]), do: intersect([a, intersect(r)])

  def split_in_2(l), do: Enum.split(l, div(length(l), 2)) |> Tuple.to_list()

  def parse_line(line) do
    line |> String.trim() |> to_charlist() |> split_in_2() |> intersect() |> hd() |> priority()
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&parse_line/1)
    |> sum()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn l -> l |> String.trim() |> to_charlist() |> MapSet.new() end)
    |> chunk_every(3)
    |> map(fn g -> intersect(g) |> hd() |> priority() end)
    |> sum()
  end
end
