defmodule AdventOfCode.Day24 do
  import Enum

  @infinity 10_000_000
  @c_to_atom %{?^ => :up, ?v => :down, ?< => :left, ?> => :right, ?# => :wall, ?. => nil}

  @deltas %{down: {1, 0}, right: {0, 1}, left: {0, -1}, up: {-1, 0}}

  def occupied(bliz) do
    :sets.from_list(for {p, _} <- bliz, do: p)
  end

  def parse(args) do
    cells =
      args
      |> String.split("\n", trim: true)
      |> with_index()
      |> map(fn {line, r} ->
        to_charlist(line) |> with_index() |> map(fn {car, c} -> {{r, c}, @c_to_atom[car]} end)
      end)
      |> List.flatten()
      |> filter(&(elem(&1, 1) != nil))

    bliz = cells |> filter(&(elem(&1, 1) != :wall))

    {{bliz, occupied(bliz)}, max(for {{_, c}, _} <- cells, do: c),
     max(for {{r, _}, _} <- cells, do: r)}
  end

  def move_bliz({{r, c}, dir}, width, height) do
    {dr, dc} = @deltas[dir]
    {r, c} = {r + dr, c + dc}

    {cond do
       r < 1 -> {height - 1, c}
       r >= height -> {1, c}
       c < 1 -> {r, width - 1}
       c >= width -> {r, 1}
       true -> {r, c}
     end, dir}
  end

  def move_all_bliz({l, _}, w, h) do
    bliz = for(b <- l, do: move_bliz(b, w, h))
    {bliz, occupied(bliz)}
  end

  def can_move({r, c} = pos, {_, busy}, w, h) do
    cond do
      :sets.is_element(pos, busy) -> false
      pos == {0, 1} or pos == {h, w - 1} -> true
      r <= 0 or r >= h or c <= 0 or c >= w -> false
      true -> true
    end
  end

  def possible_dir({r, c} = pos, bliz, w, h) do
    start = if can_move(pos, bliz, w, h), do: [{:stay, pos}], else: []

    reduce(
      @deltas,
      [],
      fn {dir, {dr, dc}}, acc ->
        {nr, nc} = {r + dr, c + dc}
        if can_move({nr, nc}, bliz, w, h), do: [{dir, {nr, nc}} | acc], else: acc
      end
    ) ++ start
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))

  def get_bliz(t, cache, w, h) do
    t = rem(t, (w - 1) * (h - 1))

    case cache[t] do
      nil ->
        {pbliz, new_cache} = get_bliz(t - 1, cache, w, h)
        new_bliz = move_all_bliz(pbliz, w, h)
        {new_bliz, Map.put(new_cache, t, new_bliz)}

      bliz ->
        {bliz, cache}
    end
  end

  def dfs([], min_steps, _, _, _, _, _), do: min_steps

  def dfs(
        [{{r, c} = pos, time} = st | to_explore],
        min_steps,
        cache_bliz,
        w,
        h,
        {rg, cg} = goal,
        memo
      ) do
    if abs(rg - r) + abs(cg - c) + time >= min_steps or :sets.is_element(st, memo) do
      dfs(to_explore, min_steps, cache_bliz, w, h, goal, memo)
    else
      memo = :sets.add_element(st, memo)
      {bliz, cache_bliz} = get_bliz(time + 1, cache_bliz, w, h)
      dirs = possible_dir(pos, bliz, w, h)

      if dirs == [] do
        dfs(to_explore, min_steps, cache_bliz, w, h, goal, memo)
      else
        finish = any?(for {_, p} <- dirs, do: p == goal)

        if finish do
          IO.inspect({time + 1}, label: "Min reached")
          dfs(to_explore, Kernel.min(time + 1, min_steps), cache_bliz, w, h, goal, memo)
        else
          to_add = for {_, p} <- dirs, do: {p, time + 1}
          to_add = sort_by(to_add, fn {{r, c}, _} -> abs(rg - r) + abs(cg - c) end)
          dfs(to_explore ++ to_add, min_steps, cache_bliz, w, h, goal, memo)
        end
      end
    end
  end

  def part1(args) do
    {bliz, w, h} = parse(args)
    {_, cache} = get_bliz(w * h, %{0 => bliz}, w, h)
    dfs([{{0, 1}, 0}], @infinity, cache, w, h, {h, w - 1}, :sets.new(version: 2))
  end

  def part2(args) do
    {bliz, w, h} = parse(args)
    {_, cache} = get_bliz(w * h, %{0 => bliz}, w, h)
    way1 = dfs([{{0, 1}, 0}], @infinity, cache, w, h, {h, w - 1}, :sets.new(version: 2))

    way2 = dfs([{{h, w - 1}, way1}], @infinity, cache, w, h, {0, 1}, :sets.new(version: 2))

    dfs([{{0, 1}, way2}], @infinity, cache, w, h, {h, w - 1}, :sets.new(version: 2))
  end
end
