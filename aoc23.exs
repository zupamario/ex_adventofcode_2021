defmodule AOC23 do
  @player_max_index 3
  @goal_exit_index %{:A => 2, :B => 4, :C => 6, :D => 8}

  def parse(_input) do
    # %{{:A,0} => {:A,1}, {:B,0} => {:A,0},
    #   {:D,0} => {:B,1}, {:C,0} => {:B,0},
    #   {:C,1} => {:C,1}, {:B,1} => {:C,0},
    #   {:A,1} => {:D,1}, {:D,1} => {:D,0}}

    # %{{:A,0} => {:A,0}, {:D,0} => {:B,0}, {:A,1} => {:C,0}, {:C,1} => {:D,0},
    #   {:C,0} => {:A,1}, {:D,1} => {:B,1}, {:B,0} => {:C,1}, {:B,1} => {:D,1}}

    # %{{:A,0} => {:A,0}, {:D,0} => {:B,0}, {:A,1} => {:C,0}, {:C,1} => {:D,0},
    #   {:C,0} => {:A,1}, {:D,1} => {:B,1}, {:B,0} => {:C,1}, {:B,1} => {:D,1},
    #   {:C,2} => {:A,2}, {:D,2} => {:B,2}, {:B,2} => {:C,2}, {:A,2} => {:D,2}}

    # %{{:A,0} => {:A,0}, {:B,0} => {:B,0}, {:C,0} => {:C,0}, {:D,0} => 10,
    #   {:D,1} => {:A,1}, {:B,1} => {:B,1}, {:C,1} => {:C,1}, {:A,1} => 0,
    #   {:A,2} => {:A,2}, {:B,2} => {:B,2}, {:C,2} => {:C,2}, {:D,2} => 9,
    #   {:D,3} => {:A,3}, {:B,3} => {:B,3}, {:C,3} => {:C,3}, {:A,3} => 1}

    # Test input part 2
    # %{{:B,0} => {:A,0}, {:C,0} => {:B,0}, {:B,2} => {:C,0}, {:D,3} => {:D,0},
    #   {:D,0} => {:A,1}, {:C,1} => {:B,1}, {:B,3} => {:C,1}, {:A,2} => {:D,1},
    #   {:D,1} => {:A,2}, {:B,1} => {:B,2}, {:A,1} => {:C,2}, {:C,3} => {:D,2},
    #   {:A,0} => {:A,3}, {:D,2} => {:B,3}, {:C,2} => {:C,3}, {:A,3} => {:D,3}}

    # Final input
    %{{:A,0} => {:A,0}, {:D,2} => {:B,0}, {:A,1} => {:C,0}, {:C,2} => {:D,0},
      {:D,0} => {:A,1}, {:C,1} => {:B,1}, {:B,1} => {:C,1}, {:A,3} => {:D,1},
      {:D,1} => {:A,2}, {:B,0} => {:B,2}, {:A,2} => {:C,2}, {:C,3} => {:D,2},
      {:C,0} => {:A,3}, {:D,3} => {:B,3}, {:B,2} => {:C,3}, {:B,3} => {:D,3}}
  end

  def move_out(position) do
    case position do
      { name, 0} ->
        exit_index = @goal_exit_index[name]
        {[exit_index], exit_index}
      { name, index} ->
        steps = Enum.map(0..index-1, fn idx -> { name, idx} end)
        steps = [@goal_exit_index[name] | steps]
        {steps, hd steps}
      _ ->
        {[], position}
    end
  end

  def move_hallway(start, position) do
    case position do
      { room_name, room_index} ->
        room_entrance = @goal_exit_index[room_name]
        to_entrance_steps = case start < room_entrance do
          true -> Enum.to_list(room_entrance..start+1)
          false -> Enum.to_list(room_entrance..start-1)
        end
        #IO.inspect(to_entrance_steps, label: "TO ENTRANCE STEPS")
        room_steps = Enum.map(room_index..0, fn idx -> { room_name, idx} end)
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

  def room_has_player(state, type, index) do
    Enum.filter(state, fn {_key, value} -> is_tuple(value) end)
    |> Enum.any?(fn {{player_type, _}, {room_type, room_index}} ->
      player_type == type and room_type == type and room_index == index
    end)
  end

  def player_is_home?({player_type, _player_idx} = player, state) do
    case state[player] do
      { ^player_type, room_index} ->
          room_index == @player_max_index or Enum.all?(room_index+1..@player_max_index, fn idx -> room_has_player(state, player_type, idx) end)
      _ ->
        false
    end
  end

  def move_costs(player_type, path) do
    num_moves = Enum.count(path)
    case player_type do
      :A -> num_moves
      :B -> num_moves * 10
      :C -> num_moves * 100
      :D -> num_moves * 1000
    end
  end

  def possible_moves({player_type, _idx} = player, state) do
    position = state[player]
    room_move = room_move(player_type, state)
    moves = case position do
      { room_name, room_index} -> [room_move,0,1,3,5,7,9,10]
      _ -> [room_move]
    end
    #IO.inspect({position, moves}, label: "PLAYER MOVES")

    possible_moves = Enum.reduce(moves, [], fn move, filtered ->
      path = compute_path(position, move)
      #IO.inspect(path, label: "MOVE PATH")
      cost = move_costs(player_type, path)
      valid = not occupied?(path, state)
      if valid, do: [{move, cost} | filtered], else: filtered
    end)
    #|> Enum.reverse()

    if possible_moves == [], do: nil, else: possible_moves
  end

  def occupied?(positions, state) do
    #IO.inspect(positions, label: "FILTERING PATH")
    occupied = MapSet.new(Map.values(state))
    Enum.any?(positions, fn pos -> MapSet.member?(occupied, pos) end)
  end

  def room_move(player_type, state) do
    Enum.reduce_while(@player_max_index..0, nil, fn idx, room ->
      if room_has_player(state, player_type, idx) do
        {:cont, nil}
      else
        {:halt, { player_type, idx}}
      end
    end)
  end

  def iterate([{state, costs} | other_states], min_costs \\ 999999999999, state_map \\ %{}) do
    #IO.inspect({costs, length(other_states), min_costs, Enum.count(state_map)}, label: "ITERATING ON STATE")
    players = Map.keys(state)
    finished = Enum.all?(players, fn player -> player_is_home?(player, state) end)

    moves = Enum.map(players, fn player ->
      if player_is_home?(player, state), do: {player, nil}, else: {player, possible_moves(player, state)}
    end)

    moves = Enum.filter(moves, fn {_, move_list} -> move_list != nil end)

    new_states = Enum.flat_map(moves, fn {player, move_list} ->
      Enum.map(move_list, fn {move, move_costs} ->
        {Map.put(state, player, move), costs + move_costs}
      end)
    end)

    #count_before = Enum.count(new_states)
    new_states = Enum.filter(new_states, fn {state, new_costs} ->
      simple_state = Enum.map(state, fn {{player_type, player_idx}, position} ->
        {position, player_type}
      end) |> Enum.sort()

      case Map.get(state_map, simple_state) do
        nil -> new_costs < min_costs
        existing_costs -> existing_costs > new_costs and new_costs < min_costs
      end
    end)
    #count_after = Enum.count(new_states)
    #IO.puts("FILTERED #{count_before - count_after} states")

    state_map = Enum.reduce(new_states, state_map, fn {state, costs}, state_map ->
      simple_state = Enum.map(state, fn {{player_type, player_idx}, position} ->
        {position, player_type}
      end) |> Enum.sort()

      Map.put(state_map, simple_state, costs)
    end)

    # if Enum.count(new_states) == 0 do
    #   IO.inspect(state, label: "NO MORE MOVES FOR STATE")
    #   Process.sleep(1000)
    # end

    new_states = new_states ++ other_states
    #new_states = Enum.sort_by(new_states, fn {_state, costs} -> costs end)

    #Process.sleep(100)
    if finished do
      IO.inspect(costs, label: "FINISHED WITH COSTS")
      min_costs = if costs < min_costs, do: costs, else: min_costs
      iterate(other_states, min_costs, state_map)
    else
      iterate(new_states, min_costs, state_map)
    end
  end

  def iterate([], _min_costs, _state_map) do
    IO.puts("NO SOLUTION FOUND")
  end

  def solve(input) do
    initial_state = parse(input)
    #recurse(initial_state)
    iterate([{initial_state, 0}])
  end
end

# IO.inspect(AOC23.compute_path({ :A, 1}, 10), label: "PATH A")
# IO.inspect(AOC23.compute_path(10, { :A, 1}), label: "PATH B")
# IO.inspect(AOC23.compute_path(0, { :C, 3}), label: "PATH C")
# IO.inspect(AOC23.compute_path({ :B, 1}, { :C, 1}), label: "PATH D")

# state = %{{:A,0} => {:A,1}, {:A,1} => {:A,0}}

# IO.inspect(AOC23.player_is_home?({:A,0}, state), label: "A")
# IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "B")

# state = %{{:A,0} => 5, {:A,1} => {:A,0}}
# IO.inspect(AOC23.player_is_home?({:A,0}, state), label: "C")
# state = %{{:A,0} => 5, {:A,1} => {:A,1}}
# IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "D")

# state = %{{:B,0} => {:A,0}, {:A,1} => {:A,1}}
# IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "E")

# state = %{{:B,0} => {:A,1}, {:A,1} => {:A,0}}
# IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "F")

# state = %{{:A,0} => 5, {:A,1} => {:C,1}}
# IO.inspect(AOC23.possible_moves({:A,0}, state), label: "POSSIBLE MOVES A")
# IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES B")

# state = %{{:A,0} => { :A, 1}, {:A,1} => {:C,1}}
# IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES C")

IO.inspect(AOC23.solve(""))

#state = AOC23.parse("")
#IO.inspect(AOC23.possible_moves({:A,0}, state), label: "POSSIBLE MOVES A0")
# IO.inspect(AOC23.possible_moves({:B,0}, state), label: "POSSIBLE MOVES B0")
# IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES A1")
#IO.inspect(AOC23.possible_moves({:D,2}, state), label: "POSSIBLE MOVES D2")
#IO.inspect(AOC23.possible_moves({:D,0}, state), label: "POSSIBLE MOVES D0")
