defmodule AdventOfCode.Day09 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn e ->
      case String.split(e, " ", trim: true) do
        ["U", n] -> {:up, String.to_integer(n), {0, 1}}
        ["D", n] -> {:down, String.to_integer(n), {0, -1}}
        ["R", n] -> {:right, String.to_integer(n), {1, 0}}
        ["L", n] -> {:left, String.to_integer(n), {-1, 0}}
      end
    end)
  end

  @one_move for dx <- -1..1, dy <- -1..1, {dx, dy} != {0, 0}, do: {dx, dy}
  def d({dx, dy}), do: dx * dx + dy * dy
  def diff({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}
  def move_t(dx, dy) when abs(dx) <= 1 and abs(dy) <= 1, do: {0, 0}

  def move_t(dx, dy) do
    for(move <- @one_move, do: {move, d(diff({dx, dy}, move))})
    |> min_by(fn {_, d} -> d end)
    |> elem(0)
  end

  def move_all_n(moves, n) do
    start_pos = List.duplicate({0, 0}, n)
    move_all_n(moves, {0, 0}, start_pos, [start_pos])
  end

  def move_all_n([], _, _, acc), do: reverse(acc)

  def move_all_n([{_d, 0, _dir} | r], h_pos, t_pos, acc), do: move_all_n(r, h_pos, t_pos, acc)

  def move_all_n([{d, n, {dx, dy}} | r], {hx, hy}, tails, acc) do
    {hx, hy} = {hx + dx, hy + dy}

    new_tails =
      reduce(tails, {{hx, hy}, []}, fn {tx, ty}, {{phx, phy}, l_tails} ->
        {dtx, dty} = move_t(phx - tx, phy - ty)
        {tx, ty} = {tx + dtx, ty + dty}
        {{tx, ty}, [{tx, ty} | l_tails]}
      end)
      |> elem(1)
      |> reverse()

    move_all_n([{d, n - 1, {dx, dy}} | r], {hx, hy}, new_tails, [new_tails | acc])
  end

  def part1(args), do: args |> parse() |> move_all_n(1) |> uniq() |> count()

  def part2(args), do: args |> parse() |> move_all_n(9) |> map(&List.last/1) |> uniq() |> count()
end
