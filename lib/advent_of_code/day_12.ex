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
    for {dr, dc} <- @adj,
        grid[{r + dr, c + dc}] != nil,
        grid[{r + dr, c + dc}] + 1 >= grid[current],
        do: {r + dr, c + dc}
  end

  def fill_dist(grid, current, dist, viewed) do
    # Ajoute le noeud courant dans la liste des noeud déjà vus (parcourus)
    viewed = MapSet.put(viewed, current)
    # Distance du noeud courant
    current_dist = dist[current]

    # Calcule les distances des noeuds accessibles adjacents
    dist =
      reduce(adjacent(current, grid), dist, fn cell, d ->
        dist_cell = if current_dist + 1 >= d[cell], do: d[cell], else: current_dist + 1
        Map.put(d, cell, dist_cell)
      end)

    # Il y a-t-il un noeud non parcouru ?
    choice_in = for {cell, d} <- dist, not MapSet.member?(viewed, cell), do: {cell, d}

    # Si non, on a terminé
    if empty?(choice_in) do
      dist
    else
      # Prendre le noeud non parcouru de distance minimale
      {current, _} = min_by(choice_in, fn {_, c} -> c end)
      # Continuer en ajoutant le nouveau noeud dans la liste des noeuds parcourus
      fill_dist(grid, current, dist, viewed)
    end
  end

  def fill_dist(grid, current) do
    infinite = count(grid)
    # Initialiser les distances à infini sauf le noeud de départ
    dist = for(cell <- Map.keys(grid), do: {cell, infinite}) |> Map.new() |> Map.put(current, 0)
    # Lancer le parcours
    fill_dist(grid, current, dist, MapSet.new())
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
