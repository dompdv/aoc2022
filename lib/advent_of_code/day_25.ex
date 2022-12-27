defmodule AdventOfCode.Day25 do
  import Enum
  @sign %{?2 => 2, ?1 => 1, ?0 => 0, ?- => -1, ?= => -2}
  @sign_1 for {k, v} <- @sign, into: %{}, do: {v, k}
  def parse_line(line) do
    line
    |> to_charlist()
    |> reverse()
    |> reduce({0, 1}, fn c, {acc, m} -> {acc + m * @sign[c], m * 5} end)
    |> elem(0)
  end

  def to_base(n, b), do: n |> Integer.to_charlist(b) |> map(&(&1 - ?0))

  def carry(l), do: carry(reverse(l), [])
  def carry([], acc), do: acc
  def carry([0 | r], acc), do: carry(r, [0 | acc])
  def carry([1 | r], acc), do: carry(r, [1 | acc])
  def carry([2 | r], acc), do: carry(r, [2 | acc])
  def carry([3], acc), do: carry([], [1, -2 | acc])
  def carry([4], acc), do: carry([], [1, -1 | acc])
  def carry([3, s | r], acc), do: carry([s + 1 | r], [-2 | acc])
  def carry([4, s | r], acc), do: carry([s + 1 | r], [-1 | acc])
  def carry([5, s | r], acc), do: carry([0, s + 1 | r], acc)

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&parse_line/1)
    |> sum()
    |> to_base(5)
    |> carry()
    |> map(&@sign_1[&1])
  end

  def part2(_args), do: nil
end
