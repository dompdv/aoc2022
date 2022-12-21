defmodule AdventOfCode.Day21 do
  import Enum

  @ops [{" + ", :plus}, {" - ", :minus}, {" * ", :mult}, {" / ", :div}]
  def parse_r(expr) do
    l = for {s, op} <- @ops, String.contains?(expr, s), do: {op, String.split(expr, s)}

    case l do
      [] -> {:num, String.to_integer(expr)}
      [{op, [l, r]}] -> {op, l, r}
    end
  end

  def parse_line(line) do
    [mkey, r] = String.split(line, ": ")
    {mkey, parse_r(r)}
  end

  def parse(args), do: String.split(args, "\n", trim: true) |> map(&parse_line/1) |> Map.new()

  def operate(:plus, ln, rn), do: ln + rn
  def operate(:minus, ln, rn), do: ln - rn
  def operate(:mult, ln, rn), do: ln * rn
  def operate(:div, ln, rn), do: ln / rn
  def operate(:equal, ln, rn), do: ln - rn

  def yell(mkeys, mkey) do
    case mkeys[mkey] do
      {:num, num} -> num
      {op, l, r} -> operate(op, yell(mkeys, l), yell(mkeys, r))
    end
  end

  def part1(args), do: args |> parse() |> yell("root") |> round()

  def create_function(mkeys), do: fn x -> Map.put(mkeys, "humn", {:num, x}) |> yell("root") end

  def find_zero(f, x) do
    f_x = f.(x)

    if abs(f_x) < 0.05,
      do: x,
      else: find_zero(f, x - 0.1 * f_x / (f.(x + 0.1) - f_x))
  end

  def part2(args) do
    args
    |> parse()
    |> Map.update!("root", fn {_, l, r} -> {:equal, l, r} end)
    |> create_function()
    |> find_zero(0)
    |> round()
  end
end
