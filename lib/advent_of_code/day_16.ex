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

  def bfs([], max_score, _), do: max_score

  def bfs(
        [%{time: 30} | r],
        max_score,
        network
      ) do
    bfs(r, max_score, network)
  end

  def bfs(
        [
          %{
            pos: current_pos,
            score: current_score,
            time: time,
            path: path,
            open_valves: open_valves,
            rem_valves: rem_valves
          }
          | r
        ],
        max_score,
        network
      ) do
    # if :rand.uniform() > 0.99, do: IO.inspect(count(r), label: "BFS")
    {current_valve, tos} = network[current_pos]

    if current_score + rem_valves * (30 - time - 1) < max_score do
      bfs(r, max_score, network)
    else
      new_states =
        for {d, to} <- tos, to not in path do
          %{
            pos: to,
            score: current_score,
            time: time + d,
            path: [to | path],
            open_valves: open_valves,
            rem_valves: rem_valves
          }
        end

      if current_valve != 0 and not MapSet.member?(open_valves, current_pos) do
        new_score = current_score + (30 - time - 1) * current_valve
        new_max_score = Kernel.max(new_score, max_score)

        new_state = %{
          pos: current_pos,
          score: new_score,
          time: time + 1,
          path: path,
          open_valves: MapSet.put(open_valves, current_pos),
          rem_valves: rem_valves - current_valve
        }

        if new_score > max_score, do: IO.inspect({new_score, new_state, count(r)})

        bfs(sort_states([new_state | new_states] ++ r), new_max_score, network)
      else
        bfs(sort_states(new_states ++ r), max_score, network)
      end
    end
  end

  def sort_states(l), do: l

  def sort_states1(l) do
    sort(
      l,
      fn %{score: score1, time: time1, rem_valves: rem_valves1},
         %{score: score2, time: time2, rem_valves: rem_valves2} ->
        #        score1 >= score2
        #        rem_valves1 <= rem_valves2
        time1 >= time2
        # score1 + rem_valves1 * (30 - time1 - 1) >= score2 + rem_valves2 * (30 - time2 - 1)
      end
    )
  end

  def add_1_to_network(network) do
    for {node, {v, nodes}} <- network, into: %{}, do: {node, {v, map(nodes, &{1, &1})}}
  end

  def part1(args) do
    network = parse(args) |> IO.inspect()
    total_valves = sum(for {_, {v, _}} <- network, do: v)

    dist_paths =
      for n <- Map.keys(network),
          do: {n, populate_dist(n, network)}

    paths = for {n, {_, p}} <- dist_paths, into: %{}, do: {n, p}
    distances = for {n, {d, _}} <- dist_paths, into: %{}, do: {n, d}
    # IO.inspect(distances, label: "dist")
    :ok
    nodes_with_valves = for {node, {v, _}} <- network, v > 0, do: node

    reduced_network =
      for node_from <- ["AA" | nodes_with_valves], into: %{} do
        {node_from,
         {network[node_from] |> elem(0),
          for node_to <- nodes_with_valves, node_from != node_to do
            {distances[node_from][node_to], node_to}
          end}}
      end

    bfs(
      [
        %{
          pos: "AA",
          score: 0,
          time: 0,
          path: ["AA"],
          open_valves: MapSet.new(),
          rem_valves: total_valves
        }
      ],
      0,
      # add_1_to_network(network)
      reduced_network
    )
  end

  def part1_old(args) do
    network = parse(args)
    total_valves = sum(for {_, {v, _}} <- network, do: v)

    bfs(
      [
        %{
          pos: "AA",
          score: 0,
          time: 0,
          path: ["AA"],
          open_valves: MapSet.new(),
          rem_valves: total_valves
        }
      ],
      0,
      network
    )
  end

  def part1_very_old(args) do
    args = """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """

    network = parse(args) |> IO.inspect()
    dist_paths = for n <- Map.keys(network), do: {n, populate_dist(n, network)}
    paths = for {n, {_, p}} <- dist_paths, into: %{}, do: {n, p}
    distances = for {n, {d, _}} <- dist_paths, into: %{}, do: {n, d}

    explore(0, "AA", 0, 0, [], MapSet.new(), network, distances, paths)
  end

  def part2(args) do
  end
end
