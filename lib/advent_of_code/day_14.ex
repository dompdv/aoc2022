defmodule AdventOfCode.Day14 do
  import Enum

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_path/1)

  def parse_path(line) do
    line
    |> String.split(" -> ")
    |> map(fn c -> String.split(c, ",") |> map(&String.to_integer/1) end)
  end

  def build_grid(paths) do
    grid = reduce(paths, [], fn path, g -> build_grid_path(path, g) end) |> uniq()
    height = for({_, y} <- grid, do: y) |> max()
    {:ordsets.from_list(grid), height}
  end

  def build_grid_path(path, g),
    do:
      chunk_every(path, 2, 1, :discard) |> reduce(g, fn line, lg -> build_grid_line(line, lg) end)

  def build_grid_line([[x1, y1], [x2, y2]], lg),
    do: lg ++ for(x <- x1..x2, y <- y1..y2, do: {x, y})

  def fall(grid), do: fall(grid, {500, 0})

  def fall({_, height}, {_, y}) when y > height, do: :out

  def fall({rocks, _} = g, {x, y}) do
    cond do
      not :ordsets.is_element({x, y + 1}, rocks) -> fall(g, {x, y + 1})
      not :ordsets.is_element({x - 1, y + 1}, rocks) -> fall(g, {x - 1, y + 1})
      not :ordsets.is_element({x + 1, y + 1}, rocks) -> fall(g, {x + 1, y + 1})
      true -> {x, y}
    end
  end

  def fill(g), do: fill(g, 0)

  def fill({rocks, height} = g, n) do
    case fall(g) do
      :out -> n
      cell -> fill({:ordsets.add_element(cell, rocks), height}, n + 1)
    end
  end

  def part1(args), do: parse(args) |> build_grid() |> fill()

  def fall2(grid), do: fall2(grid, {500, 0})

  def fall2({_rocks, h}, {x, y}) when y == h + 1, do: {x, y}

  def fall2({rocks, _h} = g, {x, y}) do
    cond do
      not :ordsets.is_element({x, y + 1}, rocks) -> fall2(g, {x, y + 1})
      not :ordsets.is_element({x - 1, y + 1}, rocks) -> fall2(g, {x - 1, y + 1})
      not :ordsets.is_element({x + 1, y + 1}, rocks) -> fall2(g, {x + 1, y + 1})
      true -> {x, y}
    end
  end

  def fill2(g), do: fill2(g, 0)

  def fill2({rocks, height} = g, n) do
    case fall2(g) do
      {500, 0} -> n + 1
      cell -> fill2({:ordsets.add_element(cell, rocks), height}, n + 1)
    end
  end

  def part2(args), do: parse(args) |> build_grid() |> fill2()
end
