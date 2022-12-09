defmodule AdventOfCode.Day08 do
  import Enum

  def parse(args),
    do:
      args
      |> String.split("\n", trim: true)
      |> map(fn line -> to_charlist(line) |> map(&(&1 - ?0)) end)

  def visible(b) do
    reduce(with_index(b), {-1, []}, fn {h, i}, {last_h, acc} ->
      if h > last_h, do: {h, [i | acc]}, else: {last_h, acc}
    end)
    |> elem(1)
  end

  def extract_col(grid, c), do: for(line <- grid, do: at(line, c))
  def visible_row_left(grid, r, _, _), do: for(c <- visible(at(grid, r)), do: {r, c})

  def visible_row_right(grid, r, _, ncols),
    do: for(c <- visible(reverse(at(grid, r))), do: {r, ncols - c - 1})

  def visible_col_up(grid, c, _, _), do: for(r <- visible(extract_col(grid, c)), do: {r, c})

  def visible_col_down(grid, c, nrows, _),
    do: for(r <- visible(reverse(extract_col(grid, c))), do: {nrows - r - 1, c})

  def part1(args) do
    grid = parse(args)
    {nrows, ncols} = {length(grid), length(at(grid, 0))}

    lr =
      for r <- 0..(nrows - 1),
          do: visible_row_left(grid, r, nrows, ncols) ++ visible_row_right(grid, r, nrows, ncols)

    ud =
      for c <- 0..(ncols - 1),
          do: visible_col_up(grid, c, nrows, ncols) ++ visible_col_down(grid, c, nrows, ncols)

    List.flatten(lr ++ ud) |> uniq() |> count()
  end

  def distance([], _h), do: 0

  def distance(l, h) do
    reduce(l, {false, 0}, fn tree_h, {blocked, n} ->
      cond do
        blocked -> {blocked, n}
        tree_h >= h -> {true, n + 1}
        true -> {false, n + 1}
      end
    end)
    |> elem(1)
  end

  def take_right(grid, {r, c}), do: split(at(grid, r), c + 1) |> elem(1)

  def take_left(_grid, {_r, 0}), do: []
  def take_left(grid, {r, c}), do: split(at(grid, r), c) |> elem(0) |> reverse()

  def take_down(grid, {r, c}), do: split(extract_col(grid, c), r + 1) |> elem(1)

  def take_up(_, {0, _}), do: []
  def take_up(grid, {r, c}), do: split(extract_col(grid, c), r) |> elem(0) |> reverse()

  def scenic_score(grid, {r, c}) do
    height = at(grid, r) |> at(c)

    [
      take_up(grid, {r, c}),
      take_right(grid, {r, c}),
      take_down(grid, {r, c}),
      take_left(grid, {r, c})
    ]
    |> map(&distance(&1, height))
    |> reduce(1, fn e, a -> e * a end)
  end

  def part2(args) do
    grid = parse(args)
    {nrows, ncols} = {length(grid), length(at(grid, 0))}
    for(r <- 0..(nrows - 1), c <- 0..(ncols - 1), do: scenic_score(grid, {r, c})) |> max()
  end
end
