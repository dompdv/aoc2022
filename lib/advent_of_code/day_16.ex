defmodule AdventOfCode.Day16 do
  import Enum

  @mexpr ~r/Valve (.*) has flow rate=(-*\d+); tunnels? leads? to valves? (.*)/

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      [from, p, to] = Regex.run(@mexpr, line, capture: :all_but_first)
      {from, {String.to_integer(p), String.split(to, ", ", trim: true)}}
    end)
    |> Map.new()
  end

  def fill_dist(network, current, dist, viewed, paths) do
    # Ajoute le noeud courant dans la liste des noeud déjà vus (parcourus)
    viewed = MapSet.put(viewed, current)
    # Distance du noeud courant
    current_dist = dist[current]
    current_path = Map.get(paths, current, [])

    # Calcule les distances des noeuds accessibles adjacents
    {dist, paths} =
      reduce(network[current] |> elem(1), {dist, paths}, fn cell, {d, p} ->
        dist_cell = if current_dist + 1 >= d[cell], do: d[cell], else: current_dist + 1

        path_cell =
          if current_dist + 1 >= d[cell], do: Map.get(p, cell, []), else: [current | current_path]

        {Map.put(d, cell, dist_cell), Map.put(p, cell, path_cell)}
      end)

    # Il y a-t-il un noeud non parcouru ?
    choice_in = for {cell, d} <- dist, not MapSet.member?(viewed, cell), do: {cell, d}

    # Si non, on a terminé
    if empty?(choice_in) do
      {dist, paths}
    else
      # Prendre le noeud non parcouru de distance minimale
      {current, _} = min_by(choice_in, fn {_, c} -> c end)
      # Continuer en ajoutant le nouveau noeud dans la liste des noeuds parcourus
      fill_dist(network, current, dist, viewed, paths)
    end
  end

  def populate_dist(from, network) do
    nodes = network |> Map.keys() |> MapSet.new() |> MapSet.delete(from)
    distances = for n <- nodes, into: %{from => 0}, do: {n, count(nodes) + 1}
    {distance, paths} = fill_dist(network, from, distances, MapSet.new(), %{})

    new_paths =
      for {k, l} <- paths, k != from, into: %{} do
        [_ | r] = reverse(l)
        {k, r}
      end

    {distance, new_paths}
  end

  def explore(30, current_pos, score, max_score, path, open_valves, _network, _distances, _paths) do
    if :rand.uniform() > 0.999, do: IO.inspect({score, max_score, path}, label: "End")
    score
  end

  def explore(time, current_pos, score, max_score, path, open_valves, network, distances, paths) do
    #    IO.inspect({time, path}, label: "Explore")
    # best case
    max_additional_score =
      for {to, d} <- distances[current_pos], not MapSet.member?(open_valves, d) do
        Kernel.max(0, 30 - time - d - 1) * elem(network[to], 0)
      end
      |> sum()

    # |> IO.inspect(label: "Explore>")

    if score + max_additional_score < max_score do
      # IO.inspect({time, score, max_score}, label: "stop")
      nil
    else
      {current_valve, tos} = network[current_pos]

      moves =
        for(to <- tos, do: {:move, to})
        |> sort_by(fn {_, to} ->
          {to in paths, not MapSet.member?(open_valves, to), -elem(network[to], 0)}
        end)

      coups =
        if(MapSet.member?(open_valves, current_pos) or current_valve == 0,
          do: [],
          else: [{:open, current_pos}]
        ) ++ moves

      reduce(coups, max_score, fn
        {:open, pos} = shot, max_s ->
          new_score =
            explore(
              time + 1,
              pos,
              score + (30 - time - 1) * current_valve,
              max_s,
              [shot | path],
              MapSet.put(open_valves, pos),
              network,
              distances,
              paths
            )

          cond do
            new_score == nil -> max_s
            new_score >= max_s -> new_score
            true -> max_s
          end

        {:move, pos} = shot, max_s ->
          new_score =
            explore(
              time + 1,
              pos,
              score,
              max_s,
              [shot | path],
              open_valves,
              network,
              distances,
              paths
            )

          cond do
            new_score == nil -> max_s
            new_score >= max_s -> new_score
            true -> max_s
          end
      end)
    end
  end

  def part1(args) do
    network = parse(args)
    dist_paths = for n <- Map.keys(network), do: {n, populate_dist(n, network)}
    paths = for {n, {_, p}} <- dist_paths, into: %{}, do: {n, p}
    distances = for {n, {d, _}} <- dist_paths, into: %{}, do: {n, d}

    explore(0, "AA", 0, 0, [], MapSet.new(), network, distances, paths)
  end

  def part2(args) do
  end
end
