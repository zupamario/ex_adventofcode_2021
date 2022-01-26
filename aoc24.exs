defmodule AOC24 do
  def parse(source_code) do
    source_code
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line) end)
    |> Enum.map(fn [instruction | parameters] ->
      parameters = Enum.map(parameters, fn parameter ->
        case Integer.parse(parameter) do
          :error -> String.to_atom(parameter)
          {value, _remainder} -> value
        end
      end)

      case instruction do
        "inp" -> {:inp, parameters}
        "add" -> {:add, parameters}
        "mul" -> {:mul, parameters}
        "div" -> {:div, parameters}
        "mod" -> {:mod, parameters}
        "eql" -> {:eql, parameters}
      end
    end)
  end

  def inp(a, [next_digit | rest], state) do
    state = %{state | a => next_digit}
    {rest, state}
  end

  def add(a, b, state) do
    case is_atom(b) do
      true -> %{state | a => state[a] + state[b]}
      false -> %{state | a => state[a] + b}
    end
  end

  def mul(a, b, state) do
    case is_atom(b) do
      true -> %{state | a => state[a] * state[b]}
      false -> %{state | a => state[a] * b}
    end
  end

  def div(a, b, state) do
    case is_atom(b) do
      true -> %{state | a => div(state[a], state[b])}
      false -> %{state | a => div(state[a], b)}
    end
  end

  def mod(a, b, state) do
    case is_atom(b) do
      true -> %{state | a => rem(state[a], state[b])}
      false -> %{state | a => rem(state[a], b)}
    end
  end

  def eql(a, b, state) do
    eql = case is_atom(b) do
      true -> if state[a] == state[b], do: 1, else: 0
      false -> if state[a] == b, do: 1, else: 0
    end
    %{state | a => eql}
  end

  def evaluate([instruction | rest], input, state) do
    #IO.inspect(instruction, label: "PROCESSING INSTRUCTION")
    {input, state} = case instruction do
      {:inp, [a]} -> inp(a, input, state)
      {:add, [a,b]} -> {input, add(a, b, state)}
      {:mul, [a,b]} -> {input, mul(a, b, state)}
      {:div, [a,b]} -> {input, div(a, b, state)}
      {:mod, [a,b]} -> {input, mod(a, b, state)}
      {:eql, [a,b]} -> {input, eql(a, b, state)}
    end
    evaluate(rest, input, state)
  end

  def evaluate([], _, state) do
    state
  end

  def solve(source_code) do
    program = parse(source_code)
    initial_state = %{:x => 0, :y => 0, :z => 0, :w => 0}

    Enum.each(9..1, fn number ->
      #number = Integer.to_charlist(number) |> Enum.map(fn i -> i - 48 end)
      state = evaluate(program, [1,9,9,9,8,4,1,1,4,8,1,3,1,9],initial_state)
      IO.inspect({number, state.z})
    end)
  end
end

input_a = "inp z
inp x
mul z 3
eql z x"

input_b = "inp w
add z w
mod z 2
div w 2
add y w
mod y 2
div w 2
add x w
mod x 2
div w 2
mod w 2"

input = "inp w
mul x 0
add x z
mod x 26
div z 1
add x 13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 8
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 12
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 13
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 12
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 8
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 10
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 10
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -11
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 12
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -13
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 1
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 15
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 13
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 10
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 5
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -2
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 10
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -6
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 3
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 1
add x 14
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 2
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x 0
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 2
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -15
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 12
mul y x
add z y
inp w
mul x 0
add x z
mod x 26
div z 26
add x -4
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y 7
mul y x
add z y"

IO.inspect(AOC24.solve(input))
