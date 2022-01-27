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

  def evaluate(_, _, state, 0) do
    state
  end

  def evaluate([instruction | rest], input, state, instruction_count \\ 18) do
    #IO.inspect(state.z, label: "PROCESSING INSTRUCTION")
    {input, state} = case instruction do
      {:inp, [a]} -> inp(a, input, state)
      {:add, [a,b]} -> {input, add(a, b, state)}
      {:mul, [a,b]} -> {input, mul(a, b, state)}
      {:div, [a,b]} -> {input, div(a, b, state)}
      {:mod, [a,b]} -> {input, mod(a, b, state)}
      {:eql, [a,b]} -> {input, eql(a, b, state)}
    end
    #if rem(instruction_count, 18) == 0, do: IO.puts("Z: #{state.z}")
    evaluate(rest, input, state, instruction_count - 1)
  end

  def evaluate([], _, state, _) do
    state
  end

  def solve_3(source_code) do
    program = parse(source_code)
    initial_state = %{:x => 0, :y => 0, :z => 0, :w => 0}
    Enum.each(1000..0, fn number ->
      initial_state = %{:x => 0, :y => 0, :z => number, :w => 0}
      state = evaluate(program, [9], initial_state, 18)
      #state = evaluate(program, [9,9,9,9,9,9,9,9,9,9,9,9,9,9], initial_state, 14*18)
      #if state.z == 0, do: IO.puts("#{number}: #{state.z}")
      IO.puts("#{number}: #{state.z}")
    end)
  end

  def solve_2(source_code) do
    program = parse(source_code)
    initial_state = %{:x => 0, :y => 0, :z => 0, :w => 0}
    Enum.each(9..1, fn number ->
      state = evaluate(program, [9,3,9,9,8,4,1,1,4,8,1,3,1,1], initial_state, 14*18)
      #state = evaluate(program, [9,9,9,9,9,9,9,9,9,9,9,9,9,9], initial_state, 14*18)
      IO.puts("#{number}: #{state.z}\n")
    end)
  end

  def solve(source_code) do
    program = parse(source_code)
    initial_state = %{:x => 0, :y => 0, :z => 0, :w => 0}

    table = :ets.new(:min_value, [:set, :protected])
    :ets.insert(table, {:minimum, 9999999999999})

    Enum.each(99999999999999..11111111111111, fn number ->
      number = Integer.to_charlist(number) |> Enum.map(fn i -> i - 48 end)
      #number = number ++ [1,1,1,1,1,1,1,1]
      if Enum.all?(number, fn n -> n > 0 end) do
        #state = evaluate(program, [1,3,9,9,8,4,1,1,4,8,1,3,1,9],initial_state)
        state = evaluate(program, number,initial_state, 14*18)
        #IO.inspect({number, state.z})
        [{:minimum, minimum}] = :ets.lookup(table, :minimum)

        if state.z < minimum do
          :ets.insert(table, {:minimum, state.z})
          IO.puts("NEW MINIMUM #{state.z}")
          #Process.sleep(1000)
        end
      end
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

input_0 = "inp w
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
add z y"

input_1 = "inp w
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
add z y"

input_2 = "inp w
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
add z y"

input_3 = "inp w
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
add z y"

input_11 = "inp w
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
add z y"

input_12 = "inp w
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
add z y"

input_13 = "inp w
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
add z y"

input_14 = "inp w
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

IO.inspect(AOC24.solve_3(input_11), label: "INPUT")
#IO.inspect(AOC24.solve(input_0), label: "INPUT 0")
#IO.inspect(AOC24.solve(input_1), label: "INPUT 1")
#IO.inspect(AOC24.solve(input_2), label: "INPUT 2")
#IO.inspect(AOC24.solve(input_3), label: "INPUT 3")
