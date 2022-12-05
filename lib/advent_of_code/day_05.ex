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

  def parse_cranes(depart) do
    [numbers | r] = String.split(depart, "\n", trim: true) |> reverse()
    slots = numbers |> String.split(" ", trim: true) |> map(&String.to_integer/1) |> max()
    size = length(r)

    for s <- 0..(slots - 1) do
      for(n <- 0..(size - 1), do: get_crate(r, n, s))
      |> filter(fn e -> e != nil and e != 32 end)
      |> reverse()
    end
  end

  def parse(args) do
    [depart, instructions] = String.split(args, "\n\n", trim: true)
    {parse_cranes(depart), parse_instructions(instructions)}
  end

  def move_1(slots, from, to) do
    [t | r] = at(slots, from - 1)
    slots |> List.replace_at(from - 1, r) |> List.replace_at(to - 1, [t | at(slots, to - 1)])
  end

  def move(slots, n, from, to),
    do: reduce(1..n, slots, fn _, s_local -> move_1(s_local, from, to) end)

  def move_block(slots, n, from, to) do
    {t, r} = split(at(slots, from - 1), n)
    slots |> List.replace_at(from - 1, r) |> List.replace_at(to - 1, t ++ at(slots, to - 1))
  end

  def part1(args) do
    {slots, ins} = args |> parse()
    reduce(ins, slots, fn [n, from, to], s -> move(s, n, from, to) end) |> map(&hd/1)
  end

  def part2(args) do
    {slots, ins} = args |> parse()
    reduce(ins, slots, fn [n, from, to], s -> move_block(s, n, from, to) end) |> map(&hd/1)
  end
end
