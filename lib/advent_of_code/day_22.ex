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

  def move({:fwd, steps}, {pos, dir}, maze, w, type),
    do: reduce(1..steps, {pos, dir}, fn _, p -> fwd(p, maze, w, type) end)

  def move(t, {pos, dir}, _maze, _, _type), do: {pos, turn(dir, t)}

  def fwd({{r, c}, dir} = pos, maze, _, :simple) do
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

  def fwd({{r, c}, dir} = pos, maze, w, :dice) do
    {dr, dc} = @vect[dir]

    case Map.get(maze, {r + dr, c + dc}, nil) do
      0 ->
        {{r + dr, c + dc}, dir}

      1 ->
        pos

      nil ->
        {{r, c}, new_dir} = find_next({r, c}, dir, maze, w)
        if maze[{r, c}] == 1, do: pos, else: {{r, c}, new_dir}
    end
  end

  def which_side({r, c}, w) when r < w and c < 2 * w, do: 1
  def which_side({r, _c}, w) when r < w, do: 3
  def which_side({r, _c}, w) when r < 2 * w, do: 2
  def which_side({r, c}, w) when r < 3 * w and c < w, do: 4
  def which_side({r, _c}, w) when r < 3 * w, do: 6
  def which_side(_, _), do: 5

  def find_next({r, c}, dir, _maze, w) do
    case {which_side({r, c}, w), dir} do
      {1, :north} ->
        {{3 * w + c - w, 0}, :east}

      {1, :west} ->
        {{3 * w - 1 - r, 0}, :east}

      {2, :east} ->
        {{w - 1, 2 * w + (r - w)}, :north}

      {2, :west} ->
        {{2 * w, r - w}, :south}

      {3, :north} ->
        {{4 * w - 1, c - 2 * w}, :north}

      {3, :east} ->
        {{2 * w + (w - 1 - r), 2 * w - 1}, :west}

      {3, :south} ->
        {{w + (c - 2 * w), 2 * w - 1}, :west}

      {4, :north} ->
        {{w + c, w}, :east}

      {4, :west} ->
        {{w - 1 - (r - 2 * w), w}, :east}

      {5, :east} ->
        {{3 * w - 1, w + (r - 3 * w)}, :north}

      {5, :south} ->
        {{0, 2 * w + c}, :south}

      {5, :west} ->
        {{0, w + r - 3 * w}, :south}

      {6, :east} ->
        {{w - 1 - (r - 2 * w), 3 * w - 1}, :west}

      {6, :south} ->
        {{c + 2 * w, w - 1}, :west}
    end
  end

  def part1(args) do
    {maze, inst} = parse(args)
    width = round(:math.sqrt(count(maze) / 6))
    dep = jump_next({0, 0}, :east, maze)

    {{r, c}, dir} =
      reduce(inst, {dep, :east}, fn ins, p -> move(ins, p, maze, width, :simple) end)

    1000 * (r + 1) + 4 * (c + 1) + @signal[dir]
  end

  def part2(args) do
    {maze, inst} = parse(args)
    width = round(:math.sqrt(count(maze) / 6))

    dep = jump_next({0, 0}, :east, maze)

    {{r, c}, dir} = reduce(inst, {dep, :east}, fn ins, p -> move(ins, p, maze, width, :dice) end)

    1000 * (r + 1) + 4 * (c + 1) + @signal[dir]
  end
end
