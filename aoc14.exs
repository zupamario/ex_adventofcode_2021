defmodule AOC14 do
  def parse(input) do
    lines = String.split(input, "\n")
    template = (hd lines) |> String.to_charlist()
    rules = Enum.reduce(lines, %{}, fn line, rules ->
      case Regex.run(~r"(\w+) -> (\w+)", line, capture: :all_but_first) do
        [pair, insert] -> Map.put(rules, String.to_charlist(pair), hd String.to_charlist(insert))
        _ -> rules
      end
    end)
    IO.puts("#{Enum.count(rules)} RULES")
    IO.puts("#{Map.values(rules) |> Enum.uniq() |> Enum.count()} SYMBOLS")
    {template, rules}
  end

  def apply_rules({input, _rules}, 0) do
    input
  end

  def apply_rules({[head | rest], rules}, num_steps) do
    IO.puts("APPLYING RULE #{num_steps} #{Enum.count(rest)}")
    {output, _} = Enum.reduce(rest, {[head], head}, fn char, {output, last_char} ->
      case Map.get(rules, [last_char, char]) do
        nil -> {[char | output], char}
        insert -> {[char | [insert | output]], char}
      end
    end)
    output = Enum.reverse(output)
    #IO.inspect(output, label: "OUTPUT")
    apply_rules({output, rules}, num_steps - 1)
  end

  def apply_rules_smart({pair_counts, rules}, 0) do
    pair_counts
    |> Enum.reduce(%{}, fn {[a,b], count}, frequencies ->
      frequencies
      |> Map.update(b, count, fn existing -> existing  + count end)
    end)
  end

  def apply_rules_smart({pair_counts, rules}, num_steps) do
    IO.puts("APPLYING RULE #{num_steps} #{inspect pair_counts}")
    new_pair_counts = Enum.reduce(pair_counts, %{}, fn {pair, count}, new_pair_counts ->
      to_insert = Map.get(rules, pair)

      new_pair_counts
      |> Map.update([Enum.at(pair, 0), to_insert], count, fn existing -> existing  + count end)
      |> Map.update([to_insert, Enum.at(pair, 1)], count, fn existing -> existing  + count end)
    end)
    IO.inspect(new_pair_counts, label: "AFTER RULE")
    IO.inspect(Map.values(new_pair_counts) |> Enum.sum(), label: "AFTER RULE COUNT")

    apply_rules_smart({new_pair_counts, rules}, num_steps - 1)
  end

  def prepare_initial_pairs({template, rules}) do
    pairs = template
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.frequencies()
    {pairs, rules}
  end

  def solve(input) do
    {min, max} = input
    |> parse()
    |> IO.inspect(label: "PARSED INPUT")
    |> apply_rules(2)
    |> Enum.frequencies()
    |> IO.inspect()
    |> Map.values()
    |> Enum.sort()
    |> Enum.min_max()
    max - min
  end

  def solve_smart(input) do
    {template, rules} = input
    |> parse()
    |> IO.inspect(label: "PARSED INPUT")

    # Need to add first because apply_rules_smart is not accounting for the first template char
    [first | _rest] = template

    {min, max} = {template, rules}
    |> prepare_initial_pairs()
    |> IO.inspect()
    |> apply_rules_smart(40)
    |> Map.update(first, 1, fn existing -> existing  + 1 end)
    |> IO.inspect(label: "FREQUENCIES")
    |> Map.values()
    |> Enum.sort()
    |> Enum.min_max()
    max - min
  end
end

input_test = "NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"

input_test_2 = "NN

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C"

input = "KKOSPHCNOCHHHSPOBKVF

NV -> S
OK -> K
SO -> N
FN -> F
NB -> K
BV -> K
PN -> V
KC -> C
HF -> N
CK -> S
VP -> H
SK -> C
NO -> F
PB -> O
PF -> P
VC -> C
OB -> S
VF -> F
BP -> P
HO -> O
FF -> S
NF -> B
KK -> C
OC -> P
OV -> B
NK -> B
KO -> C
OH -> F
CV -> F
CH -> K
SC -> O
BN -> B
HS -> O
VK -> V
PV -> S
BO -> F
OO -> S
KB -> N
NS -> S
BF -> N
SH -> F
SB -> S
PP -> F
KN -> H
BB -> C
SS -> V
HP -> O
PK -> P
HK -> O
FH -> O
BC -> N
FK -> K
HN -> P
CC -> V
FO -> F
FP -> C
VO -> N
SF -> B
HC -> O
NN -> K
FC -> C
CS -> O
FV -> P
HV -> V
PO -> H
BH -> F
OF -> P
PC -> V
CN -> O
HB -> N
CF -> P
HH -> K
VH -> H
OP -> F
BK -> S
SP -> V
BS -> V
VB -> C
NH -> H
SN -> K
KH -> F
OS -> N
NP -> P
VN -> V
KV -> F
KP -> B
VS -> F
NC -> F
ON -> S
FB -> C
SV -> O
PS -> K
KF -> H
CP -> H
FS -> V
VV -> H
CB -> P
PH -> N
CO -> N
KS -> K"

IO.inspect(AOC14.solve_smart(input))
