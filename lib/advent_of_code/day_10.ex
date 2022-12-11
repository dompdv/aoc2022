defmodule AdventOfCode.Day10 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn
      "noop" -> :noop
      "addx " <> n -> {:addx, String.to_integer(n)}
    end)
  end

  def tick([], ticks), do: reverse(ticks) |> Map.new()

  def tick([:noop | r], [{t, x} | _] = ticks), do: tick(r, [{t + 1, x} | ticks])

  def tick([{:addx, n} | r], [{t, x} | _] = ticks) do
    tick(r, [{t + 2, x + n}, {t + 1, x} | ticks])
  end

  def part1(args) do
    simul = args |> parse() |> tick([{0, 1}])
    sum(for c <- [20, 60, 100, 140, 180, 220], do: c * simul[c - 1])
  end

  def part2(args) do
    simul = args |> parse() |> tick([{0, 1}])

    grid =
      for i <- 0..239 do
        pos = rem(i, 40)
        sprite = simul[i]
        display = if pos == sprite - 1 or pos == sprite or pos == sprite + 1, do: "#", else: " "
        {{div(i, 40), pos}, display}
      end
      |> Map.new()

    for r <- 0..5 do
      for(c <- 0..39, do: grid[{r, c}]) |> join() |> IO.puts()
    end

    :ok
  end
end
