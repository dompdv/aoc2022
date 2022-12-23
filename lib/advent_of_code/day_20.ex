defmodule AdventOfCode.Day20 do
  import Enum

  def reverse_if(l, b), do: if(b, do: reverse(l), else: l)
  def move(l), do: move(with_index(l), with_index(l))

  def move([], l), do: l
  def move([{0, _} | r], l), do: move(r, l)

  def move([{n, inum} = num | r], l) do
    l = reverse_if(l, n < 0)

    current_index = find_index(l, &(elem(&1, 1) == inum))
    {_, cleaned_list} = List.pop_at(l, current_index)
    len = length(cleaned_list)
    new_index = rem(abs(n) + current_index, len)

    new_list =
      reduce(with_index(cleaned_list), [], fn {e, i}, acc ->
        if i == new_index, do: [e, num | acc], else: [e | acc]
      end)
      |> reverse_if(n > 0)

    move(r, new_list)
  end

  def part1(args) do
    initial = args |> String.split("\n", trim: true) |> map(&String.to_integer/1)
    mix = move(initial) |> map(&elem(&1, 0))
    len = length(mix)
    index_0 = find_index(mix, &(&1 == 0))
    for(delta <- [1000, 2000, 3000], do: at(mix, rem(delta + index_0, len))) |> sum()
  end

  def part2(args) do
    initial =
      args
      |> String.split("\n", trim: true)
      |> map(&String.to_integer/1)
      |> map(&(&1 * 811_589_153))
      |> with_index()

    mix =
      reduce(1..10, initial, fn _, acc -> move(initial, acc) end)
      |> map(&elem(&1, 0))

    len = length(mix)
    index_0 = find_index(mix, &(&1 == 0))
    for(delta <- [1000, 2000, 3000], do: at(mix, rem(delta + index_0, len))) |> sum()
  end
end
