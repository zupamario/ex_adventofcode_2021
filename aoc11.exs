defmodule AOC11 do
  def parse(input) do
    lines = String.split(input, "\n")
    col_cnt = byte_size(Enum.at(lines, 0))
    data = Enum.join(lines)
    |> String.to_charlist()
    |> Enum.reduce({%{}, 0}, fn x, {map, flat_idx} ->
      idx = from_flat_index(flat_idx, col_cnt)
      {Map.put(map, idx, x - 48), flat_idx + 1}
    end)
    |> elem(0)
  end

  def from_flat_index(idx, col_cnt) do
    {Integer.mod(idx, col_cnt), div(idx, col_cnt)}
  end

  def simulate(octos, steps) do
    Enum.reduce(1..steps, {octos, 0}, fn idx, {octos, flash_count} ->
      {octos, flash_count_step} = step(octos, idx)
      IO.inspect(flash_count + flash_count_step, label: "FLASH COUNT")
      {octos, flash_count + flash_count_step}
    end)
    |> elem(1)
  end

  def step(octos, step) do
    octos
    #|> IO.inspect(label: "STEPPING OCTOS")
    |> increase_energy()
    #|> IO.inspect(label: "INCREASE ENERGY")
    |> fire(0, 1)
    #|> IO.inspect(label: "FIRE")
    |> check_all_fired(step)
    |> reset()
  end

  def increase_energy(octos) do
    Enum.map(octos, fn {key, value} ->
      {key, value + 1}
    end)
    |> Enum.into(%{})
  end

  def fire(octos, total_fire_count, 0) do
    {octos, total_fire_count}
  end

  def fire(octos, total_fire_count, new_fire_count) do
    {new_octos, fire_count} = octos
    |> Enum.reduce({octos, 0}, fn {pos, energy}, {new_octos, current_fire_count} ->
      cond do
        energy != :fired and energy > 9 ->
          #IO.puts("FIREEEEE #{IO.inspect energy}")
          new_octos = %{new_octos | pos => :fired}
          {increase_neighbors(new_octos, pos), current_fire_count + 1}
        true ->
          {new_octos, current_fire_count}
      end
    end)
    #|> IO.inspect(label: "AFTER FIRE")

    fire(new_octos, total_fire_count + fire_count, fire_count)
  end

  def increase_neighbors(octos, {x, y}) do
    [{x-1,y+1}, {x,y+1}, {x+1,y+1},
     {x-1,y}  , {x,y}  , {x+1,y},
     {x-1,y-1}, {x,y-1}, {x+1, y-1}]
    |> Enum.reduce(octos, fn n, octos ->
      value = Map.get(octos, n)
      if value != nil and value != :fired, do: Map.replace(octos, n , value+1), else: octos
    end)
  end

  def reset({octos, fire_count}) do
    octos = Enum.map(octos, fn {key, value} ->
      case value do
        :fired -> {key, 0}
        _ -> {key, value}
      end
    end)
    |> Enum.into(%{})
    {octos, fire_count}
  end

  def check_all_fired({octos, fire_count}, step) do
    if Enum.all?(octos, fn {_key, value} -> value == :fired end) do
      IO.puts("ALL FIRED AT STEP #{step}")
    end
    {octos, fire_count}
  end

  def solve(input) do
    input
    |> parse()
    |> IO.inspect(label: "PARSED INPUT")
    |> simulate(500)
  end
end

input_test = "5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526"

input = "8624818384
3725473343
6618341827
4573826616
8357322142
6846358317
7286886112
8138685117
6161124267
3848415383"

IO.inspect(AOC11.solve(input))
