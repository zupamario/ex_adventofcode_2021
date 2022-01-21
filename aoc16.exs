defmodule AOC16 do
  def parse(input) do
    input
    |> to_charlist()
    |> Enum.flat_map(&hex_to_binary/1)
  end

  def hex_to_binary(hex_char) do
    case hex_char do
      ?0 -> '0000'
      ?1 -> '0001'
      ?2 -> '0010'
      ?3 -> '0011'
      ?4 -> '0100'
      ?5 -> '0101'
      ?6 -> '0110'
      ?7 -> '0111'
      ?8 -> '1000'
      ?9 -> '1001'
      ?A -> '1010'
      ?B -> '1011'
      ?C -> '1100'
      ?D -> '1101'
      ?E -> '1110'
      ?F -> '1111'
    end
  end

  def read_single_packet(bitstring) do
    {remaining, {version, id}} = read_header(bitstring)
    {remaining, payload} = case id do
      4 -> read_literal_values(remaining)
      _ -> read_operator(remaining)
    end
    IO.inspect({version, id}, label: "VERSION + ID")
    IO.inspect(payload, label: "PAYLOAD")
    IO.inspect(remaining, label: "REST")
    packet = {{version, id}, payload}
    {remaining, packet}
  end

  def read_packets('', packets) do
    {'', Enum.reverse(packets)}
  end

  def read_packets(bitstring, packets) when length(bitstring) < 6  do
    {bitstring, Enum.reverse(packets)}
  end

  def read_packets(bitstring, packets) do
    {remaining, packet} = read_single_packet(bitstring)
    read_packets(remaining, [packet | packets])
  end

  def read_header(bitstring) do
    {packet_version, rest} = Enum.split(bitstring, 3)
    {packet_id, rest} = Enum.split(rest, 3)
    {rest, {List.to_integer(packet_version, 2), List.to_integer(packet_id, 2)}}
  end

  def read_literal_values(bitstring, all_bits \\ []) do
    {[control | bits], rest} = Enum.split(bitstring, 5)
    all_bits = all_bits ++ bits
    IO.inspect(bits, label: "READ BITS")
    case control do
      ?0 -> {rest, List.to_integer(all_bits, 2)}
      ?1 -> read_literal_values(rest, all_bits)
    end
  end

  def read_operator(bitstring) do
    IO.inspect(bitstring, label: "READ OPERATOR")
    {length_type, rest} = Enum.split(bitstring, 1)
    {rest, payload} = case length_type do
      '0' -> read_operator_total_length(rest)
      '1' -> read_operator_packet_count(rest)
    end
    {rest, payload}
  end

  def read_operator_total_length(bitstring) do
    {length, rest} = Enum.split(bitstring, 15)
    length = List.to_integer(length, 2)
    IO.inspect(length, label: "LENGTH")
    {packet_data, rest} = Enum.split(rest, length)
    {'', packets} = read_packets(packet_data, [])
    IO.inspect(rest, label: "AFTER OPERATOR READ")
    {rest, packets}
  end

  def read_operator_packet_count(bitstring) do
    {length, rest} = Enum.split(bitstring, 11)
    length = List.to_integer(length, 2)
    IO.inspect(length, label: "LENGTH")
    {rest, packets} = Enum.reduce(1..length, {rest, []}, fn _idx, {rest, packets} ->
      {rest, packet} = read_single_packet(rest)
      {rest, [packet | packets]}
    end)
    {rest, Enum.reverse(packets)}
  end

  def version_sum({{version, 4}, _value}) do
    version
  end

  def version_sum({{version, _}, nested_packets}) do
    version + Enum.reduce(nested_packets, 0, fn packet, acc ->
      acc + version_sum(packet)
    end)
  end

  def evaluate_expression({{_version, 4}, value}) do
    value
  end

  def evaluate_expression({{_version, 0}, nested_packets}) do
    # SUM
    Enum.reduce(nested_packets, 0, fn packet, acc ->
      acc + evaluate_expression(packet)
    end)
  end

  def evaluate_expression({{_version, 1}, nested_packets}) do
    # PRODUCT
    Enum.reduce(nested_packets, 1, fn packet, acc ->
      acc * evaluate_expression(packet)
    end)
  end

  def evaluate_expression({{_version, 2}, nested_packets}) do
    # MIN
    nested_values = Enum.reduce(nested_packets, [], fn packet, acc ->
      [evaluate_expression(packet) | acc]
    end)
    Enum.min(nested_values)
  end

  def evaluate_expression({{_version, 3}, nested_packets}) do
    # MAX
    nested_values = Enum.reduce(nested_packets, [], fn packet, acc ->
      [evaluate_expression(packet) | acc]
    end)
    Enum.max(nested_values)
  end

  def boolean_to_integer(true), do: 1
  def boolean_to_integer(false), do: 0

  def evaluate_expression({{_version, 5}, nested_packets}) do
    # GREATER
    nested_values = Enum.reduce(nested_packets, [], fn packet, acc ->
      [evaluate_expression(packet) | acc]
    end)
    nested_values = Enum.reverse(nested_values)
    IO.inspect(nested_values, label: "GRATER")
    res = Enum.at(nested_values, 0) > Enum.at(nested_values, 1)
    boolean_to_integer(res)
  end

  def evaluate_expression({{_version, 6}, nested_packets}) do
    # LESS
    nested_values = Enum.reduce(nested_packets, [], fn packet, acc ->
      [evaluate_expression(packet) | acc]
    end)
    nested_values = Enum.reverse(nested_values)
    IO.inspect(nested_values, label: "LESS")
    res = Enum.at(nested_values, 0) < Enum.at(nested_values, 1)
    boolean_to_integer(res)
  end

  def evaluate_expression({{_version, 7}, nested_packets}) do
    # EQUAL
    nested_values = Enum.reduce(nested_packets, [], fn packet, acc ->
      [evaluate_expression(packet) | acc]
    end)
    (Enum.at(nested_values, 0) == Enum.at(nested_values, 1))
    |> boolean_to_integer()
  end

  def solve(input) do
    input
    |> parse()
    |> read_single_packet()
    |> elem(1)
    |> IO.inspect()
    #|> version_sum()
    |> evaluate_expression()
  end
end

input_literal = "D2FE28"
input_operator_length = "38006F45291200"
input_operator_count = "EE00D40C823060"
input_test_a = "8A004A801A8002F478"
input_test_b = "620080001611562C8802118E34"
input_test_c = "C0015000016115A2E0802F182340"
input_test_d = "A0016C880162017C3686B18A3D4780"

input_test_e = "C200B40A82"
input_test_f = "04005AC33890"
input_test_g = "880086C3E88112"
input_test_h = "CE00C43D881120"
input_test_i = "D8005AC2A8F0"
input_test_j = "F600BC2D8F"
input_test_k = "9C005AC2F8F0"
input_test_l = "9C0141080250320F1802104A08"

input = "805311100469800804A3E488ACC0B10055D8009548874F65665AD42F60073E7338E7E5C538D820114AEA1A19927797976F8F43CD7354D66747B3005B401397C6CBA2FCEEE7AACDECC017938B3F802E000854488F70FC401F8BD09E199005B3600BCBFEEE12FFBB84FC8466B515E92B79B1003C797AEBAF53917E99FF2E953D0D284359CA0CB80193D12B3005B4017968D77EB224B46BBF591E7BEBD2FA00100622B4ED64773D0CF7816600B68020000874718E715C0010D8AF1E61CC946FB99FC2C20098275EBC0109FA14CAEDC20EB8033389531AAB14C72162492DE33AE0118012C05EEB801C0054F880102007A01192C040E100ED20035DA8018402BE20099A0020CB801AE0049801E800DD10021E4002DC7D30046C0160004323E42C8EA200DC5A87D06250C50015097FB2CFC93A101006F532EB600849634912799EF7BF609270D0802B59876F004246941091A5040402C9BD4DF654967BFDE4A6432769CED4EC3C4F04C000A895B8E98013246A6016CB3CCC94C9144A03CFAB9002033E7B24A24016DD802933AFAE48EAA3335A632013BC401D8850863A8803D1C61447A00042E3647B83F313674009E6533E158C3351F94C9902803D35C869865D564690103004E74CB001F39BEFFAAD37DFF558C012D005A5A9E851D25F76DD88A5F4BC600ACB6E1322B004E5FE1F2FF0E3005EC017969EB7AE4D1A53D07B918C0B1802F088B2C810326215CCBB6BC140C0149EE87780233E0D298C33B008C52763C9C94BF8DC886504E1ECD4E75C7E4EA00284180371362C44320043E2EC258F24008747785D10C001039F80644F201217401500043A2244B8D200085C3F8690BA78F08018394079A7A996D200806647A49E249C675C0802609D66B004658BA7F1562500366279CCBEB2600ACCA6D802C00085C658BD1DC401A8EB136100"

IO.inspect(AOC16.solve(input))
