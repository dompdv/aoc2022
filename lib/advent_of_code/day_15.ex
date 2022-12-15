defmodule AdventOfCode.Day15 do
  import Enum

  @mexpr ~r/Sensor at x=(-*\d+), y=(-*\d+): closest beacon is at x=(-*\d+), y=(-*\d+)/

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      [xs, ys, xb, yb] =
        Regex.run(@mexpr, line, capture: :all_but_first)
        |> map(&String.to_integer/1)

      {{xs, ys}, {xb, yb}, d({xs, ys}, {xb, yb})}
    end)
    |> post_process()
  end

  def post_process(args) do
    sensors = for {s, _, r} <- args, do: {s, r}
    beacons = for {_, b, _} <- args, do: b
    {sensors, beacons}
  end

  def d({xs, ys}, {xb, yb}), do: abs(xb - xs) + abs(yb - ys)

  def merge_intervals({a, b}, {c, d}) when b < c - 1, do: [{a, b}, {c, d}]
  def merge_intervals({a, b}, {c, d}) when b >= c - 1 and b <= d, do: {a, d}
  def merge_intervals({a, b}, {_c, _d}), do: {a, b}

  def merge_intervals_list([], acc, false), do: acc |> reverse()

  def merge_intervals_list([i], acc, false), do: [i | acc] |> reverse()

  def merge_intervals_list([], acc, true), do: acc |> reverse() |> merge_intervals_list([], false)

  def merge_intervals_list([i], acc, true),
    do: [i | acc] |> reverse() |> merge_intervals_list([], false)

  def merge_intervals_list([a, b | r], acc, merged) do
    case merge_intervals(a, b) do
      [a, b] -> merge_intervals_list([b | r], [a | acc], merged)
      c -> merge_intervals_list([c | r], acc, true)
    end
  end

  def merge_intervals_list(l), do: merge_intervals_list(sort(l), [], false)

  def slice_sensors(sensors, y) do
    for {{xs, ys}, r} <- sensors, abs(y - ys) <= r do
      {xs - (r - abs(y - ys)), xs + (r - abs(y - ys))}
    end
    |> merge_intervals_list()
    |> IO.inspect()
  end

  def part1(args) do
    {sensors, beacons} = parse(args)
    y_ref = 2_000_000

    [{l, h}] = slice_sensors(sensors, y_ref)
    inside = for {bx, by} <- beacons, by == y_ref, bx >= l or bx <= h, do: bx
    h - l + 1 - count(uniq(inside))
  end

  def part2(args) do
    sensors = args |> parse() |> elem(0)

    {bx, by} =
      reduce_while(0..4_000_000, nil, fn y, _ ->
        merged =
          for {{xs, ys}, r} <- sensors, abs(y - ys) <= r do
            {xs - (r - abs(y - ys)), xs + (r - abs(y - ys))}
          end
          |> merge_intervals_list()

        if count(merged) == 1, do: {:cont, nil}, else: {:halt, {elem(hd(merged), 1) + 1, y}}
      end)

    bx * 4_000_000 + by
  end
end
