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

        bfs([new_state | new_states] ++ r, new_max_score, network)
      else
        bfs(new_states ++ r, max_score, network)
      end
    end
  end

  def reduce_network(network) do
    dist_paths =
      for n <- Map.keys(network),
          do: {n, populate_dist(n, network)}

    distances = for {n, {d, _}} <- dist_paths, into: %{}, do: {n, d}
    nodes_with_valves = for {node, {v, _}} <- network, v > 0, do: node

    for node_from <- ["AA" | nodes_with_valves], into: %{} do
      {node_from,
       {network[node_from] |> elem(0),
        for node_to <- nodes_with_valves, node_from != node_to do
          {distances[node_from][node_to], node_to}
        end}}
    end
  end

  def init_state(network) do
    total_valves = sum(for {_, {v, _}} <- network, do: v)

    [
      %{
        pos: "AA",
        score: 0,
        time: 0,
        path: ["AA"],
        open_valves: MapSet.new(),
        rem_valves: total_valves
      }
    ]
  end

  def part1(args) do
    network = parse(args) |> IO.inspect()
    bfs(init_state(network), 0, reduce_network(network))
  end

  def init_state2(network) do
    total_valves = sum(for {_, {v, _}} <- network, do: v)

    [
      %{
        posn: "AA",
        pose: "AA",
        score: 0,
        timen: 0,
        timee: 0,
        path: ["AA"],
        open_valves: MapSet.new(),
        rem_valves: total_valves
      }
    ]
  end

  def bfs2([], max_score, _), do: max_score

  def bfs2(
        [%{timen: timen, timee: timee} | r],
        max_score,
        network
      )
      when timen >= 26 and timee >= 26 do
    bfs2(r, max_score, network)
  end

  def bfs2(
        [
          %{
            posn: current_posn,
            pose: current_pose,
            score: current_score,
            timen: timen,
            timee: timee,
            path: path,
            open_valves: open_valves,
            rem_valves: rem_valves
          }
          | r
        ],
        max_score,
        network
      ) do
    {current_valven, tosn} = network[current_posn]
    {current_valvee, tose} = network[current_pose]

    if current_score + rem_valves * (26 - Kernel.min(timen, timee) - 1) < max_score do
      bfs2(r, max_score, network)
    else
      can_gon = for {dn, ton} <- tosn, timen + dn < 26, ton not in path, do: {dn, ton}
      can_gon = if empty?(can_gon), do: [{1, current_posn}], else: can_gon
      can_goe = for {de, toe} <- tose, timee + de < 26, toe not in path, do: {de, toe}
      can_goe = if empty?(can_goe), do: [{1, current_pose}], else: can_goe

      new_states =
        for {dn, ton} <- can_gon do
          for {de, toe} <- can_goe, toe != ton do
            %{
              posn: ton,
              pose: toe,
              score: current_score,
              timen: timen + dn,
              timee: timee + de,
              path: [ton, toe | path],
              open_valves: open_valves,
              rem_valves: rem_valves
            }
          end
        end
        |> List.flatten()

      {current_valven, current_valvee} =
        cond do
          current_valven != current_valvee -> {current_valven, current_valvee}
          timen <= timee -> {current_valven, 0}
          true -> {0, current_valvee}
        end

      open_valven =
        if current_valven != 0 and not MapSet.member?(open_valves, current_posn) and timen < 26 do
          {true, (26 - timen - 1) * current_valven}
        else
          false
        end

      open_valvee =
        if current_valvee != 0 and not MapSet.member?(open_valves, current_pose) and timee < 26 do
          {true, (26 - timee - 1) * current_valvee}
        else
          false
        end

      case {open_valven, open_valvee} do
        {false, false} ->
          bfs2(new_states ++ r, max_score, network)

        {{true, dscoren}, false} ->
          new_score = current_score + dscoren
          new_max_score = Kernel.max(new_score, max_score)

          new_state = %{
            posn: current_posn,
            pose: current_pose,
            score: new_score,
            timen: timen + 1,
            timee: timee + 1,
            path: path,
            open_valves: open_valves |> MapSet.put(current_posn),
            rem_valves: rem_valves - current_valven
          }

          if new_score > max_score, do: IO.inspect({new_score, new_state, count(r)})

          bfs2([new_state | new_states] ++ r, new_max_score, network)

        {false, {true, dscoree}} ->
          new_score = current_score + dscoree
          new_max_score = Kernel.max(new_score, max_score)

          new_state = %{
            posn: current_posn,
            pose: current_pose,
            score: new_score,
            timen: timen + 1,
            timee: timee + 1,
            path: path,
            open_valves: open_valves |> MapSet.put(current_pose),
            rem_valves: rem_valves - current_valvee
          }

          if new_score > max_score, do: IO.inspect({new_score, new_state, count(r)})

          bfs2([new_state | new_states] ++ r, new_max_score, network)

        {{true, dscoren}, {true, dscoree}} ->
          new_score = current_score + dscoren + dscoree
          new_max_score = Kernel.max(new_score, max_score)

          new_state = %{
            posn: current_posn,
            pose: current_pose,
            score: new_score,
            timen: timen + 1,
            timee: timee + 1,
            path: path,
            open_valves: open_valves |> MapSet.put(current_posn) |> MapSet.put(current_pose),
            rem_valves: rem_valves - current_valven - current_valvee
          }

          if new_score > max_score, do: IO.inspect({new_score, new_state, count(r)})

          bfs2([new_state | new_states] ++ r, new_max_score, network)
      end
    end
  end

  def part2(args) do
    # args = test_args()
    network = parse(args) |> IO.inspect()
    bfs2(init_state2(network), 0, reduce_network(network))
  end

  def test_args,
    do: """
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
end
