defmodule AOC12 do
  defp downcase?(input), do: input == String.downcase(input)

  defp sort_end_start(["end", other]), do: [other, "end"]
  defp sort_end_start([other, "start"]), do: ["start", other]
  defp sort_end_start(any), do: any

  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(%{}, fn connection, acc ->
      [from, to] = String.split(connection, "-")
      |> sort_end_start()

      acc = Map.get_and_update(acc, from, fn current_to ->
        if current_to == nil, do: {current_to, [to]}, else: {current_to, [to | current_to]}
      end)
      |> elem(1)

      if from != "start" and to != "end" do
        Map.get_and_update(acc, to, fn current_to ->
          if current_to == nil, do: {current_to, [from]}, else: {current_to, [from | current_to]}
        end)
        |> elem(1)
      else
        acc
      end
    end)
    |> IO.inspect()
  end

  def trace_paths(connections) do
    connections["start"]
    |> Enum.map(fn conn -> [conn, "start"] end)
    |> IO.inspect()
    |> trace_paths([], connections)
    |> Enum.count()
    #|> Enum.map(&Enum.reverse/1)
    #|> Enum.map(&Enum.join(&1, ","))
    #|> Enum.each(&IO.puts/1)
  end

  def trace_paths([path | rest], valid_paths, all_connections) do
    [last_step | _] = path
    small_cave_visited_twice = Enum.frequencies(path) |> Enum.any?(fn {key, value} -> downcase?(key) and value > 1 end)
    cond do
      last_step == "end" ->
        trace_paths(rest, [path | valid_paths], all_connections)
      true ->
        all_connections[last_step]
        |> Enum.filter(fn c -> not downcase?(c) or c not in path or not small_cave_visited_twice end)
        |> Enum.reduce(rest, fn c, rest ->
          [[c | path] | rest]
        end)
        |> trace_paths(valid_paths, all_connections)
    end

  end

  def trace_paths([], valid_paths, _) do
    valid_paths
  end

  def solve(input) do
    input
    |> parse()
    |> trace_paths()
  end
end

input_test = "start-A
start-b
A-c
A-b
b-d
A-end
b-end"

input_test_2 = "dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"

input_test_3 = "fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"

input = "xz-end
CJ-pt
pt-QW
hn-SP
pw-CJ
SP-end
hn-pt
GK-nj
fe-nj
CJ-nj
hn-ZZ
hn-start
hn-fe
ZZ-fe
SP-nj
SP-xz
ZZ-pt
nj-ZZ
start-ZZ
hn-GK
CJ-end
start-fe
CJ-xz"

IO.inspect(AOC12.solve(input))
