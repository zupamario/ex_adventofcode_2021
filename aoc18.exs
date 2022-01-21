defmodule AOC18 do
  def parse(input) do
    input
    # |> String.split("\n")
    # |> Enum.map(&String.to_charlist/1)
    # |> Enum.map(&parse_tree/1)
    |> Code.eval_string()
    |> elem(0)
  end

  def parse_tree(tree, current_node \\ nil, tree \\ [])

  def parse_tree([], _, _) do
    IO.puts("END")
  end

  def parse_tree([head | rest], current_node, tree) do
    case head do
      ?[ -> IO.puts("[")
      ?] -> IO.puts("]")
      ?, -> IO.puts(",")
      _ -> IO.puts(head - 48)
    end
    parse_tree(rest, current_node, tree)
  end

  def traverse_tree(tree_list, nesting \\ [])

  def traverse_tree([a,b], nesting) when is_integer(a) and is_integer(b) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER AB")
    IO.inspect(a)
    IO.inspect([:l | nesting])
    IO.inspect(b)
    IO.inspect([:r | nesting])

    if Enum.count(nesting) == 4, do: {[a,b], nesting}, else: nil
  end

  def traverse_tree([a,b], nesting) when is_integer(a) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER A")
    IO.inspect(a)
    traverse_tree(b, [:r | nesting])
  end

  def traverse_tree([a,b], nesting) when is_integer(b) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER B")
    traverse_tree(a, [:l | nesting])
    IO.inspect(b)
  end

  def traverse_tree([a,b] = tree_list, nesting) when is_list(tree_list) do
    IO.inspect(tree_list, label: "TRAVERSE TWO LISTS")
    res = traverse_tree(a, [:l | nesting])
    if res, do: res, else:  traverse_tree(b, [:r | nesting])
  end



  def zero_node(tree_list, path, nesting \\ [])

  def zero_node([a,b], path, nesting) when is_integer(a) and is_integer(b) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER AB")
    IO.inspect(a)
    IO.inspect([:l | nesting])
    IO.inspect(b)
    IO.inspect([:r | nesting])

    if path == nesting, do: 0, else: [a,b]
  end

  def zero_node([a,b], path, nesting) when is_integer(a) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER A")
    IO.inspect(a)
    [a, zero_node(b, path, [:r | nesting])]
  end

  def zero_node([a,b], path, nesting) when is_integer(b) do
    IO.inspect([a,b], label: "TRAVERSE INTEGER B")
    [zero_node(a, path, [:l | nesting]), b]
    IO.inspect(b)
  end

  def zero_node([a,b] = tree_list, path, nesting) when is_list(tree_list) do
    IO.inspect(tree_list, label: "TRAVERSE TWO LISTS")
    [zero_node(a, path, [:l | nesting]), zero_node(b, path, [:r | nesting])]
  end

  def add_left(tree, {{x,y}, path}) do

  end

  def add_right(tree, {{x,y}, path}) do

  end

  def solve(input) do
    tree = parse(input)
    |> IO.inspect()

    to_explode = traverse_tree(tree)
    IO.inspect(to_explode, label: "TO EXPLODE")
    tree = add_left(tree, to_explode)
    tree = add_right(tree, to_explode)
    tree = zero_node(tree, elem(to_explode, 1))

    #to_explode = elem(traverse_tree(tree), 1)
    #tree = zero_node(tree, to_explode)
    #tree
  end
end

input_test_a = "[[[[[9,8],1],2],3],4]"
input_test_b = "[[[[[1,1],[2,2]],[3,3]],[4,4]],[5,5]]"

IO.inspect(AOC18.solve(input_test_b))
