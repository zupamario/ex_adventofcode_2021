defmodule AOC21 do
  def parse(input) do
    lines = String.split(input, "\n")
    Enum.map(lines, fn line ->
      Regex.run(~r"Player \d+ starting position: (\d+)", line, capture: :all_but_first)
      |> Enum.at(0)
      |> String.to_integer()
    end)
    |> Enum.map(fn start_pos ->
      {start_pos, 0}
    end)
    |> List.to_tuple()
  end

  def roll_dice(dice, num_rolls) do
    dice = dice + 1
    dice = if dice == 101, do: 1, else: dice
    {dice, num_rolls + 1}
  end

  def move(pos, steps) do
    pos = pos - 1
    pos = rem(pos + steps, 10)
    pos + 1
  end

  def play({{{_pos_a, score_a}, {_pos_b, score_b}}, _dice}, num_rolls) when score_a >= 1000 or score_b >= 1000 do
    {score_a, score_b, num_rolls}
  end

  def play({{{pos_a, score_a}, {pos_b, score_b}}, dice}, num_rolls) do
    IO.inspect({{{pos_a, score_a}, {pos_b, score_b}}, dice}, label: "TURN")

    moves_a = dice
    {dice, num_rolls} = roll_dice(dice, num_rolls)
    moves_a = moves_a + dice
    {dice, num_rolls} = roll_dice(dice, num_rolls)
    moves_a = moves_a + dice
    pos_a = move(pos_a, moves_a)
    {dice, num_rolls} = roll_dice(dice, num_rolls)
    score_a = score_a + pos_a

    if score_a < 1000 do
      moves_b = dice
      {dice, num_rolls} = roll_dice(dice, num_rolls)
      moves_b = moves_b + dice
      {dice, num_rolls} = roll_dice(dice, num_rolls)
      moves_b = moves_b + dice

      pos_b = move(pos_b, moves_b)
      {dice, num_rolls} = roll_dice(dice, num_rolls)
      score_b = score_b + pos_b

      play({{{pos_a, score_a}, {pos_b, score_b}}, dice}, num_rolls)
    else
      play({{{pos_a, score_a}, {pos_b, score_b}}, dice}, num_rolls)
    end
    #{{{pos_a, score_a}, {pos_b, score_b}}, dice}
  end

  def solve(input) do
    play({parse(input), 1}, 0)
  end

  def solve_quantum(input) do
    initial_state = parse(input)
    game_states = %{initial_state => 1}
    play_quantum(game_states)
  end

  def play_quantum(states, wins \\ {0, 0})

  def play_quantum(states, wins) when states == %{} do
    IO.puts("FINISHED PLAYING")
    wins
  end

  def play_quantum(states, wins) do
    {new_states, new_wins} = Enum.reduce(states, {%{}, wins}, fn state, {new_states, new_wins} ->
      IO.inspect(state, label: "REDUCING STATE FOR A")
      move_player_a(state, new_states, new_wins)
    end)

    {new_states, new_wins} = Enum.reduce(new_states, {%{}, new_wins}, fn state, {new_states, new_wins} ->
      IO.inspect(state, label: "REDUCING STATE FOR B")
      move_player_b(state, new_states, new_wins)
    end)
    IO.inspect(Enum.count(Map.keys(new_states)), label: "STATE COUNT")
    IO.inspect(Enum.sum(Map.values(new_states)), label: "PLAY COUNT")

    #{new_states, new_wins}

    play_quantum(new_states, new_wins)
  end

  def move_player_a({{{a_pos, a_score}, state_b}, count} = state, new_states, wins) do
    IO.inspect(state, label: "MOVING PLAYER A STATE")

    {pos, score, new_count} = move_state(a_pos, a_score, count, 3, 1)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 4, 3)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 5, 6)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 6, 7)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 7, 6)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 8, 3)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {pos, score, new_count} = move_state(a_pos, a_score, count, 9, 1)
    {new_states, new_wins} = update_states_a(pos, score, new_count, state_b, new_states, new_wins)

    {new_states, new_wins}
  end

  def update_states_a(pos, score, count, state_b, states, {wins_a, wins_b}) do
    if score >= 21 do
      {states, {wins_a + count, wins_b}}
    else
      states = Map.update(states, {{pos, score}, state_b}, count, fn existing -> existing + count end)
      {states, {wins_a, wins_b}}
    end
  end

  def move_player_b({{state_a, {b_pos, b_score}}, count} = state, new_states, wins) do
    IO.inspect(state, label: "MOVING PLAYER A STATE")

    {pos, score, new_count} = move_state(b_pos, b_score, count, 3, 1)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 4, 3)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 5, 6)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 6, 7)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 7, 6)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 8, 3)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {pos, score, new_count} = move_state(b_pos, b_score, count, 9, 1)
    {new_states, new_wins} = update_states_b(pos, score, new_count, state_a, new_states, new_wins)

    {new_states, new_wins}
  end

  def update_states_b(pos, score, count, state_a, states, {wins_a, wins_b}) do
    if score >= 21 do
      {states, {wins_a, wins_b + count}}
    else
      states = Map.update(states, {state_a, {pos, score}}, count, fn existing -> existing + count end)
      {states, {wins_a, wins_b}}
    end
  end

  def move_state(pos, score, count, distance, factor) do
    pos = move(pos, distance)
    score = score + pos
    count = count * factor
    {pos, score, count}
  end

end

#input = "Player 1 starting position: 4
#Player 2 starting position: 8"

input = "Player 1 starting position: 4
Player 2 starting position: 10"

#IO.inspect(AOC21.solve(input))

IO.inspect(AOC21.solve_quantum(input))
