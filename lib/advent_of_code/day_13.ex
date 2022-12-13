defmodule AdventOfCode.Day13 do
  import Enum

  def to_number(n),
    do: reduce(n, {1, 0}, fn digit, {mul, acc} -> {mul * 10, acc + mul * digit} end) |> elem(1)

  def tokenize(s), do: tokenize(to_charlist(s), [], [])
  def tokenize([], _, tokens), do: reverse(tokens)
  def tokenize([?[ | r], _, acc), do: tokenize(r, [], [:open | acc])
  def tokenize([?] | r], [], acc), do: tokenize(r, [], [:close | acc])
  def tokenize([?] | r], n, acc), do: tokenize(r, [], [:close, to_number(n) | acc])
  def tokenize([?, | r], [], acc), do: tokenize(r, [], [:comma | acc])
  def tokenize([?, | r], n, acc), do: tokenize(r, [], [:comma, to_number(n) | acc])
  def tokenize([c | r], n, acc), do: tokenize(r, [c - ?0 | n], acc)

  def parse_line(line) when is_binary(line), do: parse_line(tokenize(line)) |> elem(1)
  def parse_line([:open | tokens]), do: parse_list(tokens, [])
  def parse_list([:close | r], acc), do: {r, reverse(acc)}

  def parse_list([:open | r], acc) do
    {r2, acc2} = parse_list(r, [])
    parse_list(r2, [acc2 | acc])
  end

  def parse_list([:comma | r], acc), do: parse_list(r, acc)
  def parse_list([number | r], acc), do: parse_list(r, [number | acc])

  def parse_pair(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def cmp([], []), do: :draw
  def cmp([], _), do: true
  def cmp(_, []), do: false

  def cmp([e1 | r1], [e2 | r2]) do
    case cmp(e1, e2) do
      :draw -> cmp(r1, r2)
      true -> true
      false -> false
    end
  end

  def cmp(a, b) when is_integer(a) and is_list(b), do: cmp([a], b)
  def cmp(a, b) when is_list(a) and is_integer(b), do: cmp(a, [b])

  def cmp(a, b), do: if(a == b, do: :draw, else: a < b)

  def cmp_pair([l, r]), do: cmp(l, r)

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
