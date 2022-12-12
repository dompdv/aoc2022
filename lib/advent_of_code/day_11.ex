defmodule AdventOfCode.Day11 do
  import Enum

  def parse_op("old * old"), do: fn x -> x * x end

  def parse_op("old * " <> n) do
    n = String.to_integer(n)
    fn x -> x * n end
  end

  def parse_op("old + " <> n) do
    n = String.to_integer(n)
    fn x -> x + n end
  end

  def parse_monkey(m) do
    [
      "Monkey " <> id,
      "  Starting items: " <> items,
      "  Operation: new = " <> op,
      "  Test: divisible by " <> divisible,
      "    If true: throw to monkey " <> iftrue,
      "    If false: throw to monkey " <> iffalse
    ] = String.split(m, "\n", trim: true)

    id = String.to_integer(String.replace(id, ":", ""))
    items = items |> String.split(", ", trim: true) |> map(&String.to_integer/1)

    {id,
     %{
       id: id,
       items: items,
       op: parse_op(op),
       divby: String.to_integer(divisible),
       iftrue: String.to_integer(iftrue),
       iffalse: String.to_integer(iffalse),
       inspected: 0
     }}
  end

  def play_keep_away(monkeys, id, bored, cm) do
    items = monkeys[id][:items]
    mkey = %{monkeys[id] | items: [], inspected: monkeys[id][:inspected] + length(items)}
    monkeys = Map.put(monkeys, id, mkey)

    reduce(items, monkeys, fn item, mkeys ->
      worry = mkey[:op].(item)
      worry = if bored, do: div(worry, 3), else: worry
      worry = rem(worry, cm)
      send_to = if rem(worry, mkey[:divby]) == 0, do: mkey[:iftrue], else: mkey[:iffalse]
      dest_monkey = mkeys[send_to]
      dest_monkey = %{dest_monkey | items: dest_monkey[:items] ++ [worry]}
      mkeys |> Map.put(send_to, dest_monkey)
    end)
  end

  def play_one_round(monkeys, bored, cm) do
    n_monkeys = count(monkeys)

    reduce(0..(n_monkeys - 1), monkeys, fn id, mkeys ->
      play_keep_away(mkeys, id, bored, cm)
    end)
  end

  def parse(args) do
    args
    |> String.split("\n\n", trim: true)
    |> map(&parse_monkey/1)
    |> Map.new()
  end

  def launch(args, bored, rounds) do
    monkeys = parse(args)
    cm = for({_, m} <- monkeys, do: m[:divby]) |> reduce(1, fn a, b -> a * b end)

    reduce(1..rounds, monkeys, fn _, mkeys ->
      play_one_round(mkeys, bored, if(bored, do: 3, else: 1) * cm)
    end)
    |> Map.to_list()
    |> map(fn {_, m} -> m[:inspected] end)
    |> sort(:desc)
    |> take(2)
    |> reduce(1, fn a, b -> a * b end)
  end

  def part1(args), do: launch(args, true, 20)
  def part2(args), do: launch(args, false, 10000)
end
