defmodule AdventOfCode.Day01 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n\n", trim: true)
    |> map(&String.split(&1, "\n", trim: true))
    |> map(fn l -> map(l, &String.to_integer/1) end)
    |> map(&sum(&1))
  end

  def part1(args) do
    args |> parse() |> max()
  end

  def part2(args) do
    args |> parse() |> sort(:desc) |> take(3) |> sum()
  end
end
