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

  def find_left(maze, r), do: min(for {{^r, c}, _} <- maze, do: c)
  def find_right(maze, r), do: max(for {{^r, c}, _} <- maze, do: c)
  def find_up(maze, c), do: min(for {{r, ^c}, _} <- maze, do: r)
  def find_down(maze, c), do: max(for {{r, ^c}, _} <- maze, do: r)

  def turn(dir, :right), do: at(@dirs, rem(find_index(@dirs, &(&1 == dir)) + 1, 4))
  def turn(dir, :left), do: at(@dirs, rem(find_index(@dirs, &(&1 == dir)) + 3, 4))

  def fwd({{r, c} = pos, dir}, maze) do
    {dr, dc} = @vect[dir]
    {r, c} = {r + dr, c + dc}

    case Map.get(maze, {r, c}, nil) do
      0 ->
        {r, c}

      1 ->
        pos

      nil ->
        {r, c} =
          case dir do
            :north -> {find_down(maze, c), c}
            :east -> {r, find_left(maze, r)}
            :south -> {find_up(maze, c), c}
            :west -> {r, find_left(maze, r)}
          end

        if maze[{r, c}] == 1, do: pos, else: {r, c}
    end
  end

  def move({:fwd, steps}, {pos, dir}, maze),
    do: {reduce(1..steps, pos, fn _, p -> fwd({p, dir}, maze) end), dir}

  def move(t, {pos, dir}, _maze), do: {pos, turn(dir, t)}

  def part1(args) do
    # args = File.read!("lib/advent_of_code/d22.txt")
    {maze, inst} = parse(args)
    dep = find_left(maze, 0) |> IO.inspect(label: "start")

    {{r, c}, dir} =
      reduce(inst, {{0, dep}, :east}, fn ins, p ->
        IO.inspect({ins, p}, label: "P-move")
        move(ins, p, maze)
      end)

    1000 * (r + 1) + 4 * (c + 1) + @signal[dir]
  end

  def part2(args) do
    args
  end

  def to_num(l),
    do: reduce(l, {0, 1}, fn n, {acc, mul} -> {acc + n * mul, mul * 10} end) |> elem(0)

  def parse_inst([], [], acc), do: reverse(acc)
  def parse_inst([], l, acc), do: reverse([to_num(l) | acc])
  def parse_inst([?L | r], [], acc), do: parse_inst(r, [], [:left | acc])
  def parse_inst([?L | r], l, acc), do: parse_inst(r, [], [:left, to_num(l) | acc])
  def parse_inst([?R | r], [], acc), do: parse_inst(r, [], [:right | acc])
  def parse_inst([?R | r], l, acc), do: parse_inst(r, [], [:right, to_num(l) | acc])
  def parse_inst([n | r], l, acc), do: parse_inst(r, [n - ?0 | l], acc)
end
