defmodule AOC6 do
  def parse(input) do
    num_fish_per_day = String.split(input, ",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
    Map.merge(%{0=>0, 1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0}, num_fish_per_day)
  end

  def simulate(fishes, 0) do
    fishes
  end

  def simulate(fishes, steps) do
    num_zero = fishes[0]
    fishes = %{fishes | 0 => fishes[1]}
    fishes = %{fishes | 1 => fishes[2]}
    fishes = %{fishes | 2 => fishes[3]}
    fishes = %{fishes | 3 => fishes[4]}
    fishes = %{fishes | 4 => fishes[5]}
    fishes = %{fishes | 5 => fishes[6]}
    fishes = %{fishes | 6 => fishes[7] + num_zero}
    fishes = %{fishes | 7 => fishes[8]}
    fishes = %{fishes | 8 => num_zero}
    #IO.inspect(fishes)
    simulate(fishes, steps - 1)
  end

  def lanternfish(input) do
    parse(input)
    |> simulate(256)
    |> Map.values()
    |> Enum.sum()
  end
end

input_test = "3,4,3,1,2"

input = "1,1,1,1,1,5,1,1,1,5,1,1,3,1,5,1,4,1,5,1,2,5,1,1,1,1,3,1,4,5,1,1,2,1,1,1,2,4,3,2,1,1,2,1,5,4,4,1,4,1,1,1,4,1,3,1,1,1,2,1,1,1,1,1,1,1,5,4,4,2,4,5,2,1,5,3,1,3,3,1,1,5,4,1,1,3,5,1,1,1,4,4,2,4,1,1,4,1,1,2,1,1,1,2,1,5,2,5,1,1,1,4,1,2,1,1,1,2,2,1,3,1,4,4,1,1,3,1,4,1,1,1,2,5,5,1,4,1,4,4,1,4,1,2,4,1,1,4,1,3,4,4,1,1,5,3,1,1,5,1,3,4,2,1,3,1,3,1,1,1,1,1,1,1,1,1,4,5,1,1,1,1,3,1,1,5,1,1,4,1,1,3,1,1,5,2,1,4,4,1,4,1,2,1,1,1,1,2,1,4,1,1,2,5,1,4,4,1,1,1,4,1,1,1,5,3,1,4,1,4,1,1,3,5,3,5,5,5,1,5,1,1,1,1,1,1,1,1,2,3,3,3,3,4,2,1,1,4,5,3,1,1,5,5,1,1,2,1,4,1,3,5,1,1,1,5,2,2,1,4,2,1,1,4,1,3,1,1,1,3,1,5,1,5,1,1,4,1,2,1"

IO.inspect(AOC6.lanternfish(input))
