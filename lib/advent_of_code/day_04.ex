defmodule AdventOfCode.Day04 do
  import Enum

  @mexpr ~r/(\d+)-(\d+),(\d+)-(\d+)/

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      Regex.run(@mexpr, line, capture: :all_but_first) |> map(&String.to_integer/1)
    end)
  end

  def contains([a, b, c, d]), do: (a <= c and b >= d) or (c <= a and d >= b)

  def overlap([a, b, c, d]) when a > c, do: overlap([c, d, a, b])
  def overlap([_a, b, c, _d]), do: b >= c

  def part1(args), do: args |> parse() |> count(&contains/1)

  def part2(args), do: args |> parse() |> count(&overlap/1)
end
