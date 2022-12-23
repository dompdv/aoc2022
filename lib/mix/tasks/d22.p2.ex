defmodule Mix.Tasks.D22.P2 do
  use Mix.Task

  import AdventOfCode.Day22

  @shortdoc "Day 22 Part 2"
  def run(args) do
    module = Atom.to_charlist(__MODULE__)
    l = length(module)
    {d, u} = {Enum.at(module, l - 5) - ?0, Enum.at(module, l - 4) - ?0}
    input = AdventOfCode.Input.get!(d * 10 + u, 2022)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
