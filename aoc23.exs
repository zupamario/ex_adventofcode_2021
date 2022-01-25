defmodule AOC23 do
  def parse(_input) do
    %{{:A,0} => {:goal,:A,1}, {:B,0} => {:goal,:A,0},
      {:D,0} => {:goal,:B,1}, {:C,0} => {:goal,:B,0},
      {:C,1} => {:goal,:C,1}, {:B,1} => {:goal,:C,0},
      {:A,1} => {:goal,:D,1}, {:D,1} => {:goal,:D,0}}
  end

  def goal_exit_index(goal_name) do
    case goal_name do
      :A -> 2
      :B -> 4
      :C -> 6
      :D -> 8
    end
  end

  def move_out(position) do
    case position do
      {:goal, name, 0} ->
        exit_index = goal_exit_index(name)
        {[exit_index], exit_index}
      {:goal, name, index} ->
        steps = Enum.map(0..index-1, fn idx -> {:goal, name, idx} end)
        steps = [goal_exit_index(name) | steps]
        {steps, hd steps}
      _ ->
        {[], position}
    end
  end

  def move_hallway(start, position) do
    case position do
      {:goal, room_name, room_index} ->
        room_entrance = goal_exit_index(room_name)
        to_entrance_steps = case start < room_entrance do
          true -> Enum.to_list(room_entrance..start+1)
          false -> Enum.to_list(room_entrance..start-1)
        end
        room_steps = Enum.map(room_index..0, fn idx -> {:goal, room_name, idx} end)
        room_steps ++ to_entrance_steps
      _ ->
        case start < position do
          true -> Enum.to_list(position..start+1)
          false -> Enum.to_list(position..start-1)
        end
    end

  end

  def compute_path(start, target) do
    {out_steps, hallway_index} = move_out(start)
    move_hallway(hallway_index, target) ++ out_steps
  end

  def can_reach_position(start, target, state) do

  end

  def possible_moves(player, state) do

  end

  def solve(input) do
    parse(input)
  end
end

#IO.inspect(AOC23.solve(""))
IO.inspect(AOC23.compute_path({:goal, :A, 1}, 10))
IO.inspect(AOC23.compute_path(10, {:goal, :A, 1}))
IO.inspect(AOC23.compute_path(0, {:goal, :C, 3}))
IO.inspect(AOC23.compute_path({:goal, :B, 1}, {:goal, :C, 1}))
