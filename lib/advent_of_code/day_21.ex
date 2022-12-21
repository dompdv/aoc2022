defmodule AdventOfCode.Day21 do
  import Enum

  def parse_r(expr) do
    cond do
      String.contains?(expr, "+") ->
        [l, r] = String.split(expr, " + ")
        {:plus, l, r}

      String.contains?(expr, "-") ->
        [l, r] = String.split(expr, " - ")
        {:minus, l, r}

      String.contains?(expr, "*") ->
        [l, r] = String.split(expr, " * ")
        {:mult, l, r}

      String.contains?(expr, "/") ->
        [l, r] = String.split(expr, " / ")
        {:div, l, r}

      true ->
        {:num, String.to_integer(expr)}
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

  def find_zero(f), do: find_zero(f, 0)

  def find_zero(f, x) do
    f_x = f.(x)

    if abs(f_x) < 0.05 do
      x
    else
      h = 0.1
      next_x = x - h * f_x / (f.(x + h) - f_x)
      find_zero(f, next_x)
    end
  end

  def part2(args) do
    f =
      args
      |> parse()
      |> Map.update!("root", fn {_, l, r} -> {:equal, l, r} end)
      |> create_function()

    find_zero(f) |> round()
  end
end
