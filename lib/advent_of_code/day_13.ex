defmodule AdventOfCode.Day13 do
  import Enum

  def parse_line(line) when is_binary(line), do: Code.eval_string(line, []) |> elem(0)

  def parse_pair(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)
  def cmp_pair([l, r]), do: cmp(l, r)

  def cmp([], []), do: :draw
  def cmp([], _), do: true
  def cmp(_, []), do: false

  def cmp([e1 | r1], [e2 | r2]) do
    first = cmp(e1, e2)
    if first == :draw, do: cmp(r1, r2), else: first
  end

  def cmp(a, b) when is_integer(a) and is_list(b), do: cmp([a], b)
  def cmp(a, b) when is_list(a) and is_integer(b), do: cmp(a, [b])

  def cmp(a, b), do: if(a == b, do: :draw, else: a < b)

  def part1(args) do
    args
    |> String.split("\n\n", trim: true)
    |> map(&parse_pair/1)
    |> with_index()
    |> reduce(0, fn {pair, i}, acc ->
      acc +
        if cmp_pair(pair), do: i + 1, else: 0
    end)
  end

  def part2(args) do
    sorted =
      (args <> "\n[[2]]\n[[6]]")
      |> String.split("\n", trim: true)
      |> map(&parse_line/1)
      |> sort(&cmp(&1, &2))

    (find_index(sorted, &(&1 == [[2]])) + 1) * (find_index(sorted, &(&1 == [[6]])) + 1)
  end
end
