defmodule AOC17 do
  def compute(n) do
    n*(n+1)/2
  end

  # def doit(pos, velocity, limit) when pos >= limit do
  #   IO.puts("pos: #{pos}, velocity: #{velocity}")
  #   doit(pos + velocity, velocity - 1, limit)
  # end

  def simulate_x(pos, velocity, range, num_steps \\ 0, hit_points \\ [])

  def simulate_x(pos, 0, range, num_steps, hitpoints) do
    IO.puts("ZERO VELOCITY #{pos}")
    if pos in range do
      [{pos, num_steps, :all_larger_steps} | hitpoints]
    else
      hitpoints
    end
  end

  def simulate_x(pos, velocity, range, num_steps, hitpoints) do
    cond do
      pos in range ->
        IO.puts("TARGET REACHED: #{pos}")
        new_hitpoints = [{pos, num_steps, :just_this_step} | hitpoints]
        simulate_x(pos + velocity, velocity - 1, range, num_steps + 1, new_hitpoints)
      pos <= range.last ->
        IO.puts("pos: #{pos}, velocity: #{velocity}, num_steps: #{num_steps}")
        simulate_x(pos + velocity, velocity - 1, range, num_steps + 1, hitpoints)
      true ->
        IO.puts("OVERSHOT TARGET AREA #{pos}")
        hitpoints
    end
  end

  def simulate_y(pos, velocity, range, num_steps \\ 0, hitpoints \\ []) do
    cond do
      pos in range ->
        IO.puts("TARGET REACHED: #{pos}")
        new_hitpoints = [{pos, num_steps} | hitpoints]
        simulate_y(pos + velocity, velocity - 1, range, num_steps + 1, new_hitpoints)
      pos >= range.last ->
        IO.puts("pos: #{pos}, velocity: #{velocity}, num_steps: #{num_steps}")
        simulate_y(pos + velocity, velocity - 1, range, num_steps + 1, hitpoints)
      true ->
        IO.puts("OVERSHOT TARGET AREA #{pos}")
        hitpoints
    end
  end

  def check_xs(range) do
    results = for n <- 1..range.last, do: {n, simulate_x(0, n, range)}
    Enum.filter(results, fn {_velocity, hitpoints} -> Enum.count(hitpoints) > 0 end)
  end

  def check_ys(range) do
    results = for n <- 0..range.last, do: {n, simulate_y(0, n, range)}
    Enum.filter(results, fn {_velocity, hitpoints} -> Enum.count(hitpoints) > 0 end)
    |> Enum.reduce([], fn {neg_vel, hitpoints} = neg_res, acc ->
      pos_vel = abs(neg_vel)-1
      pos_hitpoints = Enum.map(hitpoints, fn {pos, steps} ->
        {pos, pos_vel*2+1+steps}
      end)
      pos_res = {pos_vel, pos_hitpoints}
      [neg_res, pos_res | acc]
    end)
  end

  def gather_xy_pairs(x_range, y_range) do
    xs = check_xs(x_range)
    IO.inspect(xs, label: "XS")
    ys = check_ys(y_range)
    IO.inspect(ys, label: "YS")

    Enum.map(ys, fn y -> find_xs(y, xs) end)
    |> IO.inspect()
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end

  def find_xs({y_vel, y_hits}, xs) do
    Enum.reduce(y_hits, [], fn {_pos, step_count}, acc ->
      x_vels = find_x_velocities(xs, step_count)
      pairs = Enum.map(x_vels, fn x_vel -> {x_vel, y_vel} end)
      acc = acc ++ pairs
      acc
    end)
  end

  def find_x_velocities(xs, step_count) do
    Enum.reduce(xs, [], fn {vel, hits}, acc ->
      if Enum.any?(hits, fn hit -> valid_hit(hit, step_count) end) do
        [vel | acc]
      else
        acc
      end
    end)
  end

  def valid_hit({_pos, x_step_count, hit_type}, step_count) do
    all_larger = hit_type == :all_larger_steps and step_count >= x_step_count
    step_count == x_step_count or all_larger
  end
end

# IO.inspect(AOC17.doit(0, -248, -248))
# IO.inspect(AOC17.compute(247))

#IO.inspect(AOC17.doit(0, 8, 73))
#IO.inspect(AOC17.check_xs())
#IO.inspect(AOC17.check_ys())

#IO.inspect(AOC17.gather_xy_pairs(20..30, -5..-10), label: "RESULT")
IO.inspect(AOC17.gather_xy_pairs(29..73, -194..-248), label: "RESULT")
