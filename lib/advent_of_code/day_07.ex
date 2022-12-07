defmodule AdventOfCode.Day07 do
  import Enum

  def add_dir(fs, [], d), do: if(not Map.has_key?(fs, d), do: Map.put(fs, d, %{}), else: fs)

  def add_dir(fs, [a | r], d), do: Map.put(fs, a, add_dir(fs[a], r, d))

  def add_file(fs, [], f, s), do: Map.put(fs, f, s)

  def add_file(fs, [a | r], f, s), do: Map.put(fs, a, add_file(fs[a], r, f, s))

  def build_fs([], _, fs), do: fs
  def build_fs(["$ cd /" | r], _, fs), do: build_fs(r, ["/"], fs)
  def build_fs(["$ cd .." | r], [_ | current], fs), do: build_fs(r, current, fs)
  def build_fs(["$ cd " <> d | r], current, fs), do: build_fs(r, [d | current], fs)
  def build_fs(["$ ls" | r], current, fs), do: build_fs(r, current, fs)

  def build_fs(["dir " <> d | r], current, fs),
    do: build_fs(r, current, add_dir(fs, reverse(current), d))

  def build_fs([l | r], current, fs) do
    [size, f] = String.split(l, " ")
    build_fs(r, current, add_file(fs, reverse(current), f, String.to_integer(size)))
  end

  def file_size(fs) do
    for {_c, sub_fs} <- fs do
      if is_integer(sub_fs), do: sub_fs, else: file_size(sub_fs)
    end
    |> sum()
  end

  def find_small_directories(fs, acc) do
    dir_size = file_size(fs)

    if(dir_size <= 100_000, do: dir_size, else: 0) +
      reduce(fs, acc, fn {d, content}, local_acc ->
        local_acc +
          if is_integer(content), do: 0, else: find_small_directories(fs[d], 0)
      end)
  end

  def part1(args),
    do:
      args
      |> String.split("\n", trim: true)
      |> build_fs(nil, %{"/" => %{}})
      |> find_small_directories(0)

  def find_large_enough_directories(fs, acc, required) do
    dir_size = file_size(fs)
    acc = if dir_size >= required and dir_size < acc, do: dir_size, else: acc

    reduce(fs, acc, fn {d, content}, local_acc ->
      if is_integer(content),
        do: local_acc,
        else: find_large_enough_directories(fs[d], local_acc, required)
    end)
  end

  def part2(args) do
    fs = args |> String.split("\n", trim: true) |> build_fs(nil, %{"/" => %{}})
    root_size = file_size(fs)
    required = 30_000_000 - (70_000_000 - root_size)
    find_large_enough_directories(fs, root_size, required)
  end
end
