defmodule AdventOfCode.Day18 do
  import Enum

  @adj [{-1, 0, 0}, {1, 0, 0}, {0, -1, 0}, {0, 1, 0}, {0, 0, -1}, {0, 0, 1}]
  def add_sides([x, y, z], sides) do
    [
      {:xy, x, y, z},
      {:xy, x, y, z + 1},
      {:xz, x, y, z},
      {:xz, x, y + 1, z},
      {:yz, x, y, z},
      {:yz, x + 1, y, z} | sides
    ]
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn l -> map(String.split(l, ","), &String.to_integer/1) end)
    |> reduce([], &add_sides/2)
    |> frequencies()
    |> filter(fn {_k, v} -> v == 1 end)
    |> count()
  end

  def can_add([x, y, z], _, _, {a_min, a_max})
      when x < a_min or x > a_max or y < a_min or y > a_max or z < a_min or z > a_max,
      do: false

  def can_add(c, acc, cubes, _), do: c not in acc and c not in cubes

  def fill([], acc, _, _), do: acc

  def fill([[x, y, z] = c | r], acc, cubes, {a_min, a_max}) do
    if c in cubes or c in acc do
      fill(r, acc, cubes, {a_min, a_max})
    else
      to_consider =
        for {dx, dy, dz} <- @adj,
            can_add([x + dx, y + dy, z + dz], acc, cubes, {a_min, a_max}),
            do: [x + dx, y + dy, z + dz]

      fill(to_consider ++ r, [c | acc], cubes, {a_min, a_max})
    end
  end

  def part2(args) do
    cubes =
      args
      |> String.split("\n", trim: true)
      |> map(fn l -> map(String.split(l, ","), &String.to_integer/1) end)

    all_sides =
      cubes
      |> reduce([], &add_sides/2)
      |> frequencies()
      |> filter(fn {_k, v} -> v == 1 end)
      |> map(&elem(&1, 0))

    {a_min, a_max} = min_max(List.flatten(cubes)) |> IO.inspect(label: "minmax")
    {a_min, a_max} = {a_min - 1, a_max + 1}
    filled = fill([[a_min, a_min, a_min]], [], cubes, {a_min, a_max})

    filled_sides =
      filled
      |> reduce([], &add_sides/2)
      |> frequencies()
      |> filter(fn {_k, v} -> v == 1 end)
      |> map(&elem(&1, 0))

    MapSet.intersection(
      MapSet.new(filled_sides),
      MapSet.new(all_sides)
    )
    |> MapSet.size()
  end
end
