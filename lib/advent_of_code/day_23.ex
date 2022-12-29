defmodule AdventOfCode.Day23 do
  import Enum

  def parse(args) do
    for {line, r} <- with_index(String.split(args, "\n", trim: true)) do
      for {?#, c} <- with_index(to_charlist(line)), do: {r, c}
    end
    |> List.flatten()
  end

  def anybody_around({r, c}, {rows, _cols}) do
    any?([r - 1, r + 1, r], fn scan_r ->
      cols = rows[scan_r]

      cond do
        cols == nil ->
          false

        r == scan_r ->
          MapSet.member?(cols, c - 1) or MapSet.member?(cols, c + 1)

        true ->
          MapSet.member?(cols, c - 1) or MapSet.member?(cols, c) or MapSet.member?(cols, c + 1)
      end
    end)
  end

  def can_move({r, c}, :north, {rows, _cols}) do
    row = rows[r - 1]

    row == nil or
      not (MapSet.member?(row, c - 1) or MapSet.member?(row, c) or MapSet.member?(row, c + 1))
  end

  def can_move({r, c}, :south, {rows, _cols}) do
    row = rows[r + 1]

    row == nil or
      not (MapSet.member?(row, c - 1) or MapSet.member?(row, c) or MapSet.member?(row, c + 1))
  end

  def can_move({r, c}, :west, {_rows, cols}) do
    col = cols[c - 1]

    col == nil or
      not (MapSet.member?(col, r - 1) or MapSet.member?(col, r) or MapSet.member?(col, r + 1))
  end

  def can_move({r, c}, :east, {_rows, cols}) do
    col = cols[c + 1]

    col == nil or
      not (MapSet.member?(col, r - 1) or MapSet.member?(col, r) or MapSet.member?(col, r + 1))
  end

  def add_elf({r, c}, {rows, cols}) do
    {Map.update(rows, r, MapSet.new([c]), fn cols_for_row -> MapSet.put(cols_for_row, c) end),
     Map.update(cols, c, MapSet.new([r]), fn rows_for_col -> MapSet.put(rows_for_col, r) end)}
  end

  def build_fast_structure(elves), do: reduce(elves, {%{}, %{}}, &add_elf/2)

  def add_target(:north = d, {r, c}), do: {d, {r - 1, c}}
  def add_target(:south = d, {r, c}), do: {d, {r + 1, c}}
  def add_target(:west = d, {r, c}), do: {d, {r, c - 1}}
  def add_target(:east = d, {r, c}), do: {d, {r, c + 1}}
  def add_target(:stay = d, {r, c}), do: {d, {r, c}}

  def possible_moves(elf, order, st) do
    if anybody_around(elf, st) do
      reduce_while(order, :stay, fn dir, _ ->
        if can_move(elf, dir, st), do: {:halt, dir}, else: {:cont, :stay}
      end)
    else
      :stay
    end
    |> add_target(elf)
  end

  def round(_i, {elves, order, _}) do
    st = build_fast_structure(elves)

    proposed = for elf <- elves, do: {elf, possible_moves(elf, order, st)}

    double =
      frequencies(for {_, {_, c}} <- proposed, do: c)
      |> filter(fn {_k, v} -> v > 1 end)
      |> map(&elem(&1, 0))

    is_moving = any?(proposed, fn {_elf, {dir, dest}} -> dir != :stay and dest not in double end)

    new_elves =
      for {elf, {_, dest}} <- proposed do
        if dest in double, do: elf, else: dest
      end

    [d | r] = order
    {new_elves, r ++ [d], is_moving}
  end

  def part1(args) do
    elves = args |> parse()
    order = [:north, :south, :west, :east]
    {final, _, _} = reduce(1..10, {elves, order, true}, &round/2)
    {h, b} = min_max(for {r, _} <- final, do: r)
    {l, r} = min_max(for {_, c} <- final, do: c)
    (b - h + 1) * (r - l + 1) - count(final)
  end

  def part2(args) do
    elves = args |> parse()
    order = [:north, :south, :west, :east]

    reduce_while(Stream.iterate(1, &(&1 + 1)), {elves, order, true}, fn i, acc ->
      new_acc = round(i, acc)
      if elem(new_acc, 2), do: {:cont, new_acc}, else: {:halt, i}
    end)
  end
end
