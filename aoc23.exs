defmodule AOC23 do
  def parse(_input) do
    # %{{:A,0} => {:goal,:A,1}, {:B,0} => {:goal,:A,0},
    #   {:D,0} => {:goal,:B,1}, {:C,0} => {:goal,:B,0},
    #   {:C,1} => {:goal,:C,1}, {:B,1} => {:goal,:C,0},
    #   {:A,1} => {:goal,:D,1}, {:D,1} => {:goal,:D,0}}

    %{{:C,0} => {:goal,:A,1}, {:A,0} => {:goal,:A,0},
      {:D,0} => {:goal,:B,1}, {:D,1} => {:goal,:B,0},
      {:B,0} => {:goal,:C,1}, {:A,1} => {:goal,:C,0},
      {:B,1} => {:goal,:D,1}, {:C,1} => {:goal,:D,0}}
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

  def room_has_player(state, type, index) do
    #OM HAS PLAYER")
    Enum.filter(state, fn {_key, value} -> is_tuple(value) end)
    |> Enum.any?(fn {{player_type, _}, {_, room_type, room_index}} ->
      player_type == type and room_type == type and room_index == index
    end)
  end

  def player_is_home?({player_type, _player_idx} = player, state) do
    case state[player] do
      {:goal, ^player_type, room_index} ->
          room_index == 1 or Enum.all?(room_index+1..1, fn idx -> room_has_player(state, player_type, idx) end)
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
      {:goal, room_name, room_index} -> [room_move,0,1,3,5,7,8,9,10]
      _ -> [room_move]
    end

    possible_moves = Enum.reduce(moves, [], fn move, filtered ->
      path = compute_path(position, move)
      cost = move_costs(player_type, path)
      valid = not occupied?(path, state)
      if valid, do: [{move, cost} | filtered], else: filtered
    end)
    |> Enum.reverse()

    if possible_moves == [], do: nil, else: possible_moves
  end

  def occupied?(positions, state) do
    #IO.inspect(positions, label: "FILTERING PATH")
    occupied = MapSet.new(Map.values(state))
    Enum.any?(positions, fn pos -> MapSet.member?(occupied, pos) end)
  end

  def room_move(player_type, state) do
    Enum.reduce_while(1..0, nil, fn idx, room ->
      if room_has_player(state, player_type, idx) do
        {:cont, nil}
      else
        {:halt, {:goal, player_type, idx}}
      end
    end)
  end

  def iterate(state, call_count \\ 0, call_moves \\ [], call_costs \\ 0) do
    #IO.inspect({call_count, call_moves}, label: "ITERATE CALL COUNT")
    #Process.sleep(100)

    players = Map.keys(state)
    finished = Enum.all?(players, fn player -> player_is_home?(player, state) end)
    if finished do
      #IO.inspect(state, label: "FINISHED WITH ALL PLAYERS HOME")
      if call_costs == 15385 do
        IO.inspect(call_moves, label: "THESE ARE THE MOVES")
        IO.inspect(call_costs, label: "THIS IS THE COST")
      end
    else
      moves = Enum.map(players, fn player ->
        if player_is_home?(player, state), do: {player, nil}, else: {player, possible_moves(player, state)}
      end)

      no_more_moves = Enum.all?(moves, fn {_, moves} -> moves == nil end)
      moves = Enum.filter(moves, fn {_, move_list} -> move_list != nil end)

      if not no_more_moves and not finished do
        Enum.each(moves, fn {player, move_list} ->
          Enum.each(move_list, fn {move, move_costs} ->
            #IO.puts("MOVEING #{inspect player} -> #{inspect move}")
            new_state = Map.put(state, player, move)
            iterate(new_state, call_count + 1, [{player, move} | call_moves], call_costs + move_costs)
            if call_count == 0, do: IO.inspect({player, move}, label: "ITERATE LEVEL 1")
          end)
        end)
      end
      #IO.puts("NO MORE MOVES FOR STATE #{inspect state}")
    end
  end

  def solve(input) do
    parse(input)
    |> iterate()
  end
end

IO.inspect(AOC23.compute_path({:goal, :A, 1}, 10))
IO.inspect(AOC23.compute_path(10, {:goal, :A, 1}))
IO.inspect(AOC23.compute_path(0, {:goal, :C, 3}))
IO.inspect(AOC23.compute_path({:goal, :B, 1}, {:goal, :C, 1}))

state = %{{:A,0} => {:goal,:A,1}, {:A,1} => {:goal,:A,0}}

IO.inspect(AOC23.player_is_home?({:A,0}, state), label: "A")
IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "B")

state = %{{:A,0} => 5, {:A,1} => {:goal,:A,0}}
IO.inspect(AOC23.player_is_home?({:A,0}, state), label: "C")
state = %{{:A,0} => 5, {:A,1} => {:goal,:A,1}}
IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "D")

state = %{{:B,0} => {:goal,:A,0}, {:A,1} => {:goal,:A,1}}
IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "E")

state = %{{:B,0} => {:goal,:A,1}, {:A,1} => {:goal,:A,0}}
IO.inspect(AOC23.player_is_home?({:A,1}, state), label: "F")

state = %{{:A,0} => 5, {:A,1} => {:goal,:C,1}}
IO.inspect(AOC23.possible_moves({:A,0}, state), label: "POSSIBLE MOVES A")
IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES B")

state = %{{:A,0} => {:goal, :A, 1}, {:A,1} => {:goal,:C,1}}
IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES C")

IO.inspect(AOC23.solve(""))

#state = AOC23.parse("")
#IO.inspect(AOC23.possible_moves({:A,0}, state), label: "POSSIBLE MOVES A0")
#IO.inspect(AOC23.possible_moves({:B,0}, state), label: "POSSIBLE MOVES B0")
#IO.inspect(AOC23.possible_moves({:A,1}, state), label: "POSSIBLE MOVES A1")
