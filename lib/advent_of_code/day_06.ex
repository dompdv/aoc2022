defmodule AdventOfCode.Day06 do
  import Enum

  def start_mess([_ | r] = m, i, l) do
    {p, _} = split(m, l)
    if count(uniq(p)) == l, do: i + l, else: start_mess(r, i + 1, l)
  end

  def part1(args), do: args |> to_charlist() |> start_mess(0, 4)

  def part2(args), do: args |> to_charlist() |> start_mess(0, 14)
end
