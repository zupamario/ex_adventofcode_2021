defmodule AOC6 do
  def parse(input) do
    String.split(input, ",")
    |> Enum.map(&String.to_integer/1)
  end

  def tick_down(fishes) do
    Enum.map(fishes, fn fish ->
      if fish == 0, do: 6, else: fish - 1
    end)
  end

  def spawn_fishes(fishes) do
    Enum.reduce(fishes, fishes, fn fish, new_fishes ->
      if fish == 0, do: [9 | new_fishes], else: new_fishes
    end)
  end

  def simulate(initial, steps) do
    Enum.reduce(1..steps, initial, fn day, fishes ->
      IO.inspect(day, label: "DAY")
      #IO.inspect(fishes, label: "FISHES")
      new_fishes = spawn_fishes(fishes)
      tick_down(new_fishes)
    end)
  end

  def lanternfish(input) do
    parse(input)
    |> simulate(256)
    |> Enum.count()
  end
end

input_test = "3,4,3,1,2"

input = "1,1,1,1,1,5,1,1,1,5,1,1,3,1,5,1,4,1,5,1,2,5,1,1,1,1,3,1,4,5,1,1,2,1,1,1,2,4,3,2,1,1,2,1,5,4,4,1,4,1,1,1,4,1,3,1,1,1,2,1,1,1,1,1,1,1,5,4,4,2,4,5,2,1,5,3,1,3,3,1,1,5,4,1,1,3,5,1,1,1,4,4,2,4,1,1,4,1,1,2,1,1,1,2,1,5,2,5,1,1,1,4,1,2,1,1,1,2,2,1,3,1,4,4,1,1,3,1,4,1,1,1,2,5,5,1,4,1,4,4,1,4,1,2,4,1,1,4,1,3,4,4,1,1,5,3,1,1,5,1,3,4,2,1,3,1,3,1,1,1,1,1,1,1,1,1,4,5,1,1,1,1,3,1,1,5,1,1,4,1,1,3,1,1,5,2,1,4,4,1,4,1,2,1,1,1,1,2,1,4,1,1,2,5,1,4,4,1,1,1,4,1,1,1,5,3,1,4,1,4,1,1,3,5,3,5,5,5,1,5,1,1,1,1,1,1,1,1,2,3,3,3,3,4,2,1,1,4,5,3,1,1,5,5,1,1,2,1,4,1,3,5,1,1,1,5,2,2,1,4,2,1,1,4,1,3,1,1,1,3,1,5,1,5,1,1,4,1,2,1"

IO.inspect(AOC6.lanternfish(input))
