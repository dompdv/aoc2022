defmodule AdventOfCode.Day17 do
  import Enum

  @minus [{0, 0}, {1, 0}, {2, 0}, {3, 0}] |> reverse()
  @cross [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}] |> reverse()
  @reverse_l [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}] |> reverse()
  @vertical [{0, 0}, {0, 1}, {0, 2}, {0, 3}] |> reverse()
  @square [{0, 0}, {1, 0}, {0, 1}, {1, 1}] |> reverse()

  @rocks [@minus, @cross, @reverse_l, @vertical, @square]

  def rock(i), do: at(@rocks, rem(i, 5))
  def steam(s, i), do: at(s, rem(i, length(s)))

  def top([]), do: 0

  def top([{_, y} | _]), do: y

  def move({x, y}, ?>), do: {x + 1, y}
  def move({x, y}, ?<), do: {x - 1, y}

  def overlap(_blocks, {x, y}) when x <= 0 or x >= 8 or y <= 0, do: true
  def overlap([], _), do: false

  def overlap(blocks, {_x, y} = p) do
    reduce_while(blocks, false, fn {_bx, by} = bp, _ ->
      cond do
        p == bp -> {:halt, true}
        by < y -> {:halt, false}
        true -> {:cont, false}
      end
    end)
  end

  def overlap(blocks, a_rock, {x, y}),
    do: any?(for {dx, dy} <- a_rock, do: overlap(blocks, {x + dx, y + dy}))

  def merge_sort([], b, acc), do: reverse(acc) ++ b
  def merge_sort(a, [], acc), do: reverse(acc) ++ a

  def merge_sort([{_, a} = p | l], [{_, b} | _] = r, acc) when a > b,
    do: merge_sort(l, r, [p | acc])

  def merge_sort(l, [p | r], acc), do: merge_sort(l, r, [p | acc])

  def fill(blocks, a_rock, {x, y}),
    do: merge_sort(for({dx, dy} <- a_rock, do: {x + dx, y + dy}), blocks, [])

  def fall(blocks, a_rock, steam), do: fall(blocks, a_rock, steam, {3, 4 + top(blocks)})

  def fall(blocks, a_rock, steam, {x, y}) do
    reduce_while(
      Stream.cycle([1]),
      {blocks, {x, y}, steam},
      fn _, {c_blocks, c_pos, [s | r]} ->
        {nx, ny} = if overlap(c_blocks, a_rock, move(c_pos, s)), do: c_pos, else: move(c_pos, s)

        if overlap(c_blocks, a_rock, {nx, ny - 1}),
          do: {:halt, {fill(c_blocks, a_rock, {nx, ny}), r ++ [s]}},
          else: {:cont, {c_blocks, {nx, ny - 1}, r ++ [s]}}
      end
    )
  end

  def part1(args) do
    reduce(0..2021, {[], to_charlist(String.trim(args))}, fn i, {blocks, steam} ->
      fall(blocks, rock(i), steam)
    end)
    |> elem(0)
    |> top()
  end

  def compile_line(l) do
    reduce(l, 0, fn {x, _}, acc -> acc + 2 ** x end)
  end

  def to_byte(val) do
    t = top(val)

    lines =
      reduce(val, %{}, fn {x, y}, acc ->
        current_value = Map.get(acc, y, 0)
        Map.put(acc, y, current_value + 2 ** x)
      end)

    for l <- t..1, do: Map.get(lines, l, 0)
  end

  def part2(args) do
    # args = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
    i_steam = to_charlist(String.trim(args))
    n_numbers = (5 * count(i_steam)) |> IO.inspect(label: "n_numbers")

    all_val =
      reduce(0..n_numbers, {[], i_steam, []}, fn i, {blocks, steam, tops} ->
        if rem(i, 1000) == 0, do: IO.inspect(i)
        {new_blocks, new_steam} = fall(blocks, rock(i), steam)
        {new_blocks, new_steam, [{i, top(new_blocks)} | tops]}
      end)

    IO.inspect("To_byte.....")
    val = elem(all_val, 0)
    seq = to_byte(val)
    IO.inspect("Matching.....")

    pattern_size =
      reduce_while(1..count(seq), nil, fn size, _acc ->
        if rem(size, 100) == 0, do: IO.inspect(size)
        a = slice(seq, 0..(size - 1))
        b = slice(seq, size..(2 * size - 1))
        if a == b, do: {:halt, size}, else: {:cont, nil}
      end)
      |> IO.inspect(label: "Pattern_size")

    [{current_n, current_top} | _] = tops = elem(all_val, 2)
    {previous_n, previous_top} = find(tops, fn {_, t} -> t == current_top - pattern_size end)

    IO.inspect({{current_n, current_top}, {previous_n, previous_top}},
      label: "Current vs previous"
    )

    a = 1_000_000_000_000
    # nombre de pattern à répéter
    n_patterns = div(a - current_n, current_n - previous_n) |> IO.inspect(label: "n_patterns")

    # manque de pieces
    missing =
      (a - (n_patterns * (current_n - previous_n) + current_n)) |> IO.inspect(label: "missing")

    # hauteur des pièces pour le delta
    {_manque_n, manque_top} = find(tops, fn {p, _} -> p == previous_n + missing end)
    # hauteur
    current_top + n_patterns * pattern_size + (manque_top - previous_top) - 1
  end
end
