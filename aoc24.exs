defmodule AOC24 do
  # Lowest model number: 13621111481315
  # Highest model number: 59998426997979

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

  def possible_z_states(program, constraints, subprogram_index \\ 13)

  def possible_z_states(_program, constraints, -1) do
    constraints
  end

  def possible_z_states(program, constraints, subprogram_index) do
    # We start at the last instruction block and figure out which z-state leads to a 0 output
    # The we go through the instruction blocks one by one and ensure the z-states of the output match one possible z-state of the input.
    # along the way we remember the inputs in every stage so we can reassemble the final number
    # To get the smallest number just reverse the 1..9 range
    subprogram = Enum.slice(program, subprogram_index*18, 18)
    possible_numbers = Enum.reduce(245113..0, %{}, fn number, possible_numbers ->
      initial_state = %{:x => 0, :y => 0, :z => number, :w => 0}
      Enum.reduce(1..9, possible_numbers, fn input, possible_numbers ->
        state = evaluate(subprogram, [input], initial_state)
        # Check if current z register state is one of the required states of previous stage
        case Map.fetch(constraints, state.z) do
          {:ok, value} -> Map.put(possible_numbers, number, [input | value])
          :error -> possible_numbers
        end
      end)
    end)

    IO.puts("#{subprogram_index}, #{map_size(possible_numbers)} #{inspect possible_numbers}")
    possible_z_states(program, possible_numbers, subprogram_index - 1)
  end

  def is_valid_model_number(source_code, number) do
    program = parse(source_code)
    initial_state = %{:x => 0, :y => 0, :z => 0, :w => 0}
    state = evaluate(program, number, initial_state)
    state.z == 0
  end
end

_input_a = "inp z
inp x
mul z 3
eql z x"

_input_b = "inp w
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

input_full = "inp w
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

IO.inspect(AOC24.is_valid_model_number(input_full, [5, 9, 9, 9, 8, 4, 2, 6, 9, 9, 7, 9, 7, 9]), label: "HIGHEST MODEL NUMBER IS VALID")
IO.inspect(AOC24.possible_z_states(AOC24.parse(input_full), %{0 => []}), label: "INPUT")
