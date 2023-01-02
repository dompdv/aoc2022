defmodule AdventOfCode.Day19 do
  import Enum

  @r_complex ~r/Each (ore|clay|obsidian|geode) robot costs (\d+) (ore|clay|obsidian|geode) and (\d+) (ore|clay|obsidian|geode)/
  @r_simple ~r/Each (ore|clay|obsidian|geode) robot costs (\d+) (ore|clay|obsidian|geode)/

  @materials %{ore: 0, clay: 0, obsidian: 0, geode: 0}
  @list_l [:ore, :clay, :obsidian, :geode] |> reverse()

  def analyze(inst) do
    rules = @materials

    cond do
      Regex.match?(@r_complex, inst) ->
        [robot, n1, what1, n2, what2] = Regex.run(@r_complex, inst, capture: :all_but_first)

        {String.to_atom(robot),
         rules
         |> Map.put(String.to_atom(what1), String.to_integer(n1))
         |> Map.put(String.to_atom(what2), String.to_integer(n2))}

      Regex.match?(@r_simple, inst) ->
        [robot, n1, what1] = Regex.run(@r_simple, inst, capture: :all_but_first)
        {String.to_atom(robot), rules |> Map.put(String.to_atom(what1), String.to_integer(n1))}
    end
  end

  def parse_line(line) do
    [blueprint, r] = String.split(line, ": ")
    [_, b] = String.split(blueprint, " ")
    {String.to_integer(b), String.split(r, ". ", trim: true) |> map(&analyze/1) |> Map.new()}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def possible_robots(collect, rules) do
    for robot_m <- @list_l,
        all?(for {m, qty} <- rules[robot_m], do: collect[m] >= qty),
        do: robot_m
  end

  def diff(m1, m2), do: reduce(m2, m1, fn {k, v}, m -> Map.update!(m, k, &(&1 - v)) end)
  def search([], max_geodes, _, _, _, _), do: max_geodes

  def search([%{time: end_time} | r], max_geodes, rules, end_time, cache, maxspend),
    do: search(r, max_geodes, rules, end_time, cache, maxspend)

  def search(
        [%{robots: robots, collect: collect, time: time} = s | r],
        max_geodes,
        rules,
        end_time,
        cache,
        maxspend
      ) do
    remtime = end_time - time
    landing = collect[:geode] + remtime * div(2 * robots[:geode] + remtime, 2)

    if landing < max_geodes or :sets.is_element(s, cache) do
      #      IO.inspect("hit")
      search(r, max_geodes, rules, end_time, cache, maxspend)
    else
      cache = :sets.add_element(s, cache)

      can_build = if remtime <= 1, do: [], else: possible_robots(collect, rules)
      # ne pas construire de robot si l'on ne peut pas dépenser plus par minute que ce que l'on
      # fabrique par minute
      can_build = for r <- can_build, r == :geode or robots[r] <= maxspend[r], do: r

      # Si on peut construire un robot geode, alors on le fait
      can_build = if :geode in can_build, do: [:geode], else: can_build
      # can_build = if can_build != [], do: [hd(can_build)], else: []

      new_collect =
        reduce(robots, collect, fn {robot_m, qty_robots}, c ->
          Map.update!(c, robot_m, &(&1 + qty_robots))
        end)

      new_max_geodes = Kernel.max(max_geodes, new_collect[:geode])

      if :rand.uniform() >= 0.999999,
        do: IO.inspect({time, max_geodes, landing, robots, can_build, :sets.size(cache)})

      new_states =
        reduce(
          can_build,
          [%{robots: robots, collect: new_collect, time: time + 1}],
          fn robot, state ->
            [
              %{
                robots: Map.update!(robots, robot, &(&1 + 1)),
                collect: diff(new_collect, rules[robot]),
                time: time + 1
              }
              | state
            ]
          end
        )

      search(new_states ++ r, new_max_geodes, rules, end_time, cache, maxspend)
    end
  end

  def compute(args, time_max) do
    robots = @materials |> Map.put(:ore, 1)

    for {b, rules} <- parse(args) do
      maxspend =
        for m <- [:ore, :clay, :obsidian], into: %{}, do: {m, max(for {_, r} <- rules, do: r[m])}

      {b,
       search(
         [%{robots: robots, collect: @materials, time: 0}],
         0,
         rules,
         time_max,
         :sets.new([{:version, 2}]),
         maxspend
       )}
      |> IO.inspect()
    end
  end

  def part1(args), do: sum(for {b, q} <- compute(args, 24), do: b * q)

  def part2(args) do
    time_max = 32
    robots = @materials |> Map.put(:ore, 1)

    for {b, rules} <- take(parse(args), 3) do
      maxspend =
        for m <- [:ore, :clay, :obsidian], into: %{}, do: {m, max(for {_, r} <- rules, do: r[m])}

      {b,
       search(
         [%{robots: robots, collect: @materials, time: 0}],
         0,
         rules,
         time_max,
         :sets.new([{:version, 2}]),
         maxspend
       )}
      |> IO.inspect()
    end
    |> map(&elem(&1, 1))
    |> sort(:desc)
    |> take(3)
    |> product()
  end
end
