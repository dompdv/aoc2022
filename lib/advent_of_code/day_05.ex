defmodule AdventOfCode.Day05 do
  import Enum

  @mexpr ~r/move (\d+) from (\d+) to (\d+)/
  def parse_instructions(lines) do
    lines
    |> String.split("\n", trim: true)
    |> map(fn line ->
      Regex.run(@mexpr, line, capture: :all_but_first) |> map(&String.to_integer/1)
    end)
  end

  def get_crate(r, n, s) do
    line = at(r, n) |> to_charlist()
    if s * 4 >= length(line), do: nil, else: at(line, s * 4 + 1)
  end

  def parse_cranes([numbers | r]) do
    slots = numbers |> String.split(" ", trim: true) |> map(&String.to_integer/1) |> max()
    size = length(r)

    for s <- 0..(slots - 1) do
      for n <- 0..(size - 1) do
        get_crate(r, n, s)
      end
      |> filter(fn e -> e != nil and e != 32 end)
      |> reverse()
    end
  end

  def parse(args) do
    [depart, instructions] = String.split(args, "\n\n", trim: true)

    {
      parse_cranes(String.split(depart, "\n", trim: true) |> reverse()),
      parse_instructions(instructions)
    }
  end

  def move(slots, from, to) do
    [t | r] = at(slots, from - 1)
    d = at(slots, to - 1)
    slots |> List.replace_at(from - 1, r) |> List.replace_at(to - 1, [t | d])
  end

  def part1(args) do
    {slots, ins} = args |> parse()

    arrange =
      reduce(ins, slots, fn [n, from, to], s ->
        reduce(1..n, s, fn _, s_local -> move(s_local, from, to) end)
      end)

    for [t | _] <- arrange, do: t
  end

  def move(slots, n, from, to) do
    {t, r} = at(slots, from - 1) |> split(n)
    d = at(slots, to - 1)
    slots |> List.replace_at(from - 1, r) |> List.replace_at(to - 1, t ++ d)
  end

  def part2(args) do
    {slots, ins} = args |> parse()
    arrange = reduce(ins, slots, fn [n, from, to], s -> move(s, n, from, to) end)
    for [t | _] <- arrange, do: t
  end
end
