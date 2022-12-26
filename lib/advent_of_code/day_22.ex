defmodule AdventOfCode.Day22 do
  import Enum

  @dirs [:north, :east, :south, :west]
  @vect %{north: {-1, 0}, east: {0, 1}, south: {1, 0}, west: {0, -1}}
  @signal %{east: 0, south: 1, west: 2, north: 3}
  def parse_maze(maze) do
    String.split(maze, "\n", trim: true)
    |> with_index()
    |> map(fn {line, r} ->
      with_index(String.to_charlist(line)) |> map(fn {car, c} -> {{r, c}, car} end)
    end)
    |> List.flatten()
    |> filter(fn {_, x} -> x != 32 end)
    |> map(fn
      {c, ?.} -> {c, 0}
      {c, ?#} -> {c, 1}
    end)
    |> Map.new()
  end

  def scan_inst(inst) do
    Regex.scan(~r/(\d+)*(R|L)*/, inst, capture: :all_but_first)
    |> List.flatten()
    |> map(fn
      "R" -> :right
      "L" -> :left
      n -> {:fwd, String.to_integer(n)}
    end)
  end

  def parse(args) do
    [maze, inst] = String.split(args, "\n\n", trim: true)
    {parse_maze(maze), scan_inst(inst)}
  end

  def jump_next({_r, c}, :north, maze), do: {max(for {{r, ^c}, _} <- maze, do: r), c}
  def jump_next({r, _c}, :east, maze), do: {r, min(for {{^r, c}, _} <- maze, do: c)}
  def jump_next({_r, c}, :south, maze), do: {min(for {{r, ^c}, _} <- maze, do: r), c}
  def jump_next({r, _c}, :west, maze), do: {r, max(for {{^r, c}, _} <- maze, do: c)}

  def turn(dir, :right), do: at(@dirs, rem(find_index(@dirs, &(&1 == dir)) + 1, 4))
  def turn(dir, :left), do: at(@dirs, rem(find_index(@dirs, &(&1 == dir)) + 3, 4))

  def move({:fwd, steps}, {pos, dir}, maze, type),
    do: reduce(1..steps, {pos, dir}, fn _, p -> fwd(p, maze, type) end)

  def move(t, {pos, dir}, _maze, _type), do: {pos, turn(dir, t)}

  def fwd({{r, c}, dir} = pos, maze, :simple) do
    {dr, dc} = @vect[dir]
    {r, c} = {r + dr, c + dc}

    case Map.get(maze, {r, c}, nil) do
      0 ->
        {{r, c}, dir}

      1 ->
        pos

      nil ->
        {r, c} = jump_next({r, c}, dir, maze)
        if maze[{r, c}] == 1, do: pos, else: {{r, c}, dir}
    end
  end

  def fwd({{r, c}, dir} = pos, maze, :dice) do
    {dr, dc} = @vect[dir]
    {r, c} = {r + dr, c + dc}

    case Map.get(maze, {r, c}, nil) do
      0 ->
        {{r, c}, dir}

      1 ->
        pos

      nil ->
        {{r, c}, new_dir} = find_next({r, c}, dir, maze)
        if maze[{r, c}] == 1, do: pos, else: {{r, c}, new_dir}
    end
  end

  def find_next({r, c}, dir, maze) do
    {l, r} = min_max(for {{0, c}, _} <- maze, do: c) |> IO.inspect(label: "")
    w = r - l + 1

    side =
      cond do
        r < w -> 1
        r < 2 * w and c < w -> 4
        r < 2 * w and c < 2 * w -> 3
        r < 2 * w -> 2
        c < 3 * w -> 5
        true -> 6
      end

    case {side, dir} do
      {1, :north} ->
        {{w, 3 * w - 1 - c}, :south}

      {1, :east} ->
        {{3 * w - 1 - r, 4 * w - 1}, :west}

      {1, :west} ->
        {{w, w + r}, :south}

      {2, :east} ->
        {{2 * w, 5 * w - 1 - r}, :south}

      {3, :north} ->
        {{c - w, 2 * w}, :east}

      {3, :south} ->
        {{4 * w - 1 - c, 2 * w}, :east}

      {4, :north} ->
        {{0, 3 * w - 1 - c}, :south}

      {4, :south} ->
        {{3 * w - 1, 3 * w - 1 - c}, :north}

      {4, :west} ->
        {{3 * w - 1, 5 * w - 1 - r}, :north}

      {5, :south} ->
        {{2 * w - 1, 3 * w - 1 - c}, :north}

      {5, :west} ->
        {{2 * w - 1, 4 * w - 1 - r}, :north}

      {6, :north} ->
        {{5 * w - 1 - c, 3 * w - 1}, :west}

      {6, :east} ->
        {{3 * w - 1 - r, 3 * w - 1}, :west}

      {6, :south} ->
        {{2 * w - 1, 4 * w - 1 - c}, :east}
    end
  end

  def part1(args) do
    {maze, inst} = parse(args)
    dep = jump_next({0, 0}, :west, maze)
    {{r, c}, dir} = reduce(inst, {dep, :east}, fn ins, p -> move(ins, p, maze, :simple) end)
    1000 * (r + 1) + 4 * (c + 1) + @signal[dir]
  end

  def part2(args) do
    #    args = File.read!("lib/advent_of_code/d22.txt")
    {maze, inst} = parse(args)
    min_max(for({{_, c}, _} <- maze, do: c)) |> IO.inspect(label: "horizontal")
    min_max(for({{r, _}, _} <- maze, do: r)) |> IO.inspect(label: "vertical")
    raise "p"
    dep = jump_next({0, 0}, :west, maze)
    {{r, c}, dir} = reduce(inst, {dep, :east}, fn ins, p -> move(ins, p, maze, :dice) end)
    IO.inspect({r, c, dir})
    1000 * (r + 1) + 4 * (c + 1) + @signal[dir]
  end
end
