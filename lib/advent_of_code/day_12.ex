defmodule AdventOfCode.Day12 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, r} ->
      to_charlist(line) |> with_index() |> map(fn {car, c} -> {r, c, car} end)
    end)
    |> List.flatten()
    |> reduce({[], nil, nil}, fn
      {r, c, ?S}, {acc, _, en} -> {[{{r, c}, ?a - ?a} | acc], {r, c}, en}
      {r, c, ?E}, {acc, start, _} -> {[{{r, c}, ?z - ?a} | acc], start, {r, c}}
      {r, c, car}, {acc, start, en} -> {[{{r, c}, car - ?a} | acc], start, en}
    end)
    |> then(fn {g, s, e} -> {Map.new(g), s, e} end)
  end

  @adj [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
  def adjacent({r, c} = current, grid) do
    current_elevation = grid[current]

    for {dr, dc} <- @adj,
        grid[{r + dr, c + dc}] != nil,
        grid[{r + dr, c + dc}] + 1 >= current_elevation,
        do: {r + dr, c + dc}
  end

  def fill_dist(grid, current, dist, viewed) do
    current_dist = dist[current]

    dist =
      reduce(adjacent(current, grid), dist, fn cell, d ->
        dist_cell = if current_dist + 1 >= d[cell], do: d[cell], else: current_dist + 1
        Map.put(d, cell, dist_cell)
      end)

    choice_in = for {cell, d} <- dist, not MapSet.member?(viewed, cell), do: {cell, d}

    if empty?(choice_in) do
      dist
    else
      {current, _} = min_by(choice_in, fn {_, c} -> c end)
      fill_dist(grid, current, dist, MapSet.put(viewed, current))
    end
  end

  def fill_dist(grid, current) do
    infinite = count(grid)
    dist = for(cell <- Map.keys(grid), do: {cell, infinite}) |> Map.new() |> Map.put(current, 0)
    fill_dist(grid, current, dist, MapSet.new([current]))
  end

  def part1(args) do
    {grid, start, en} = parse(args)
    fill_dist(grid, en) |> Map.get(start)
  end

  def part2(args) do
    {grid, _start, en} = parse(args)
    dist = fill_dist(grid, en)
    for({s, elevation} <- grid, elevation == 0, do: dist[s]) |> min()
  end
end
