defmodule AOC10 do
  def parse(input) do
    String.split(input, "\n")
  end

  def first_illegal_char(line) do
    line
    |> IO.inspect(label: "ANALYZING LINE")
    |> String.to_charlist()
    |> Enum.reduce_while([], fn char, stack ->
      IO.inspect(stack, label: "ITERATION")
      cond do
        opening?(char) -> {:cont, [char | stack]}
        closing?(char) ->
          [first | rest] = stack
          if char == closing(first), do: {:cont, rest}, else: {:halt, char}
      end
    end)
  end

  def char_score(illegal_char) do
    case illegal_char do
      ?) -> 3
      ?] -> 57
      ?} -> 1197
      ?> -> 25137
    end
  end

  def closing(opening_char) do
    case opening_char do
      ?( -> ?)
      ?[ -> ?]
      ?{ -> ?}
      ?< -> ?>
    end
  end

  def opening?(char) do
    char in [?(, ?[, ?{, ?<]
  end

  def closing?(char) do
    char in [?), ?], ?}, ?>]
  end

  def completion_score(string) do
    char_score = %{?) => 1, ?] => 2, ?} => 3, ?> => 4}

    Enum.reduce(string, 0, fn char, score ->
      score = score * 5
      score = score + char_score[char]
    end)
  end

  def solve(input) do
    parse(input)
    |> Enum.map(&first_illegal_char/1)
    |> IO.inspect(label: "ILLEGAL CHARS")
    |> Enum.filter(&is_integer/1)
    |> Enum.map(&char_score/1)
    |> IO.inspect(label: "SCORES")
    |> Enum.sum()
  end

  def solve_2(input) do
    scores = parse(input)
    |> Enum.map(&first_illegal_char/1)
    |> IO.inspect(label: "ILLEGAL CHARS")
    |> Enum.filter(&is_list/1)
    |> IO.inspect(label: "INCOMPLETES")
    |> Enum.map(fn incomplete ->
      incomplete
      |> Enum.map(&closing/1)
    end)
    |> Enum.map(&completion_score/1)
    |> Enum.sort()

    Enum.at(scores, div(Enum.count(scores), 2))
  end
 end

input_test = "[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]"

input = "[{[[{(((<[{{((()<>)(<><>))[{{}{}}((){})]}[<<()[]>[{}()]>[{<>{}}<()()>]]}{{[[{}<>]({}{})]<[{}
<[({(([<[[<([[(){}]<()()>])>[[(({})[<>()])]]]<[(({()[]})[{<>{}>(<>{})])<({<>()}[<>{}])(({}<>){()<>
([{[([(((<<<{({}())<()[]>}<[[]()]{<>{}})>[{[[][]]{<><>}}]>>)[[[{{({}<>)([]<>)}}({(()[])<()[]>})](<[[()()]<{}
(<([<<({<[[[([[]{})<()[]>)(<[]()>[{}<>])]<[{[]{}}<()[]>]<[<><>]>>]<{[({})[<>{}]]<[()[]](()<>)>}{((()
{<({{<{<[<({([()<>]{<>[]})<<{}<>>>}((([]{})((){}))[[(){}](<>[])]))>][[<(<{()()>{{}[]}><{{}()}(()<>)>)
{<([<<[<(<{<<(()[])[{}[]]>>(<{()[]}>({<>()}<[]()>))}>)>[{{{({<[]><(){}>]({{}[]}<{}<>>))<{<(){}><[]{}>}({<>{}}
{[[([{<<{{(({{<>{}]<{}{}>}[<{}<>><()()>]))({({{}[]}<<>[]>)(<<>>{[][]})})}<[(({[]{}}[{}{}])<(<>())<(){
[<(<[{[<{{[<[{{}}([][])]{({}{})(<>{}]}>{<(<>[])({}())>({[]<>}{[]()})}](<{[{}]<()[]>}<([][]){{}()}>>)}<<(<[()(
<([[<{<{<[{[[{()}<[]>]]<(<[]()>)>}([([{}[]]<[]<>>)(<[][]><()<>))]{<<()[]>((){})>([{}<>]([]{}))})]{
(<({[<((([<[{([]())<<><>>)](<{[]}[{}()]>[[{}<>]((){})])>{{{{{}<>}([][])}}}]{[(((<><>)<()()>)[([]<>
<(([<(<{({{{<[()[]]<[]()>)[(<>)<<>>]}[[<(){}>[{}<>]]<[<>()]([]<>)>]}[<[{{}<>}([]{})]{[{}()]}>]})}>(({(
<<(([[{{<[<[([()[]]<()[]>)<([][]){{}<>}>]<{[()[]]({}[])}<(<>[])>>>({<<[]()>{{}})}([<{}[]>[[]()]]))
{{{<<[<[<<[<{(()[])[[]{}]}[[[]()]{{}<>}]>[{(<>)[<>()]}]]>(<{[[()<>]<{}[]>]({{}}[(){}])}{<<[]>(
<([<<[{<[[{([([][])[{}()]][(<><>)[{}<>]])[(({}{}){{}<>})]}((({[][]}<()<>>)(({}{})[()<>])))][(<(({}<
{[<{[([[{[{[<{()<>}<<>[]>>{{<>()}[<><>]}]}]([{([[][]](()()))<{[]<>}[()<>]>}{<<<>{}>{[]<>}>}))}([(<(((){}){(
({<{[{[[{({<<(()<>){<>()}>(<()>{{}()})>({[[]()][{}]}{{<>{}]{{}[]}})})}]<{{[{[<<>[]>][(<>())<<>()>]}<{<{
([(([[[{<({{{[()()]{<>{}}}}<[[[]<>][{}{}]]({()()}{()()})>}({[[(){}][[]{}]]{({}[])[{}()]}}{{[<><>]}
((<[<{(({(<<[{()()>]<(<>)<[]<>>>><{<{}[]>([]())}{{[]()}<{}<>>}>>)}))}[{(<({{{([][])[(){}]}}<<<{}<>>{{}[]}>(<{
{<[[([<([<{([([]{}){{}<>}]([[]{}]({}())))[[<{}[]>{{}<>)]{({}[])[[]]}]}(([[[]{}][<>[]]](({}[]){{}{}}))
[<<[<[({<{([<<<>{}>(()[])><({}[])[{}<>]>]<[<[][]>{()[]}}<[{}()]>>)<<<(()[])>>>}{<{<<{}()>[[]()]>{[<>(
<(<(<[({{<<[[{()<>}[{}<>]][[[]()](()<>)]]{[<()>([]<>)]<[{}{}]<{}{}>>}>([[(()()){(){}}]]<[<[][]>{[]
<[{[{{{{<({[[({}{})][<{}{}>{[]{}}]]{[[()()]{<>[]}]<[<><>]<<><>>>}})>{({(<<()()>(<>{})>{(()[
<[(([(<<(<{<(<{}<>>{{}{}})[[[][]]([]())]>{{<()>[<>{}]}({<><>}({}()))}}>[([{(<><>)[()()]}[[{}[
<((<[{([{[([({{}<>}<[][]>)[<[]<>>(<>{})]])(({[{}[]][<><>]}[{()[]}<{}{}>]))]<<{(<[][]>[<>]][{()(
((<[<<({{((<[(<>())[[]{}]]{{[][]}<<>>}>({<[]()>[[]{}]}[({}[])(()())])){({(<>[])[{}()]}[[{}{}>]){{[()<>]{
{<<{{(({(<({({{}{}}<()<>>)}([[()[]]]))>)})[{([<<<<[]<>>>({()<>})>[[[{}<>]][(<><>)(<>[])]]>])}[(<<<{(
{<[<{[<(([{[<<{}()>([]())>[{<>}{{}[]}]]}][{<[([]{})<()<>>]{{[]()>[{}[]]}>[<<<>()>[<>()]>{([]<>){[]()}}]}[
<{{<{[<<[<<<(<{}[]><()[]>)<[()()]{()[]}>>{<<<>{}>{<>[]}>[<()()>{[]{}}]}><<{{[]{}}{{}{}}}>>>[{{{([]{})<{}[]>}}
(<{(([[{[[[(<[{}()]<{}[]>>{<<>>({}{})})]]]{{{{(<[]>(())){<()[]>({}[])}}[[<(){}>[[]<>]]([{}{}]<[]{}>)]}}[<<{<[
{{((({{[((((<<<>()><[]<>>>[[[]<>]<()()>])({(<>{})}[[{}<>]<{}[]>]))[<(([]())[{}<>])[<[]{}>({}<>)]>])[<[<
{{((<([(([([([[]<>][{}<>])(([]()))])]<(((<[][]>{[]()})([{}{}]{<>()})))>))])[([{{[[[<[]{}>[<><>]]<[[]()]>]<(
<(<[[((<[[{(<{[]{}}><[{}{}][{}[]]>)[<{[]()}[[]{})><[()<>]<{}()>>]}<[<{{}[]}{<>()}>{{<><>}{{}{}}
{{[[<(<[<(<{[{[]}[{}<>]][((){})[()()]]}<([<>{}]{[]{}}){({}{})[<>]}>>{{{{<>[]}(())}{<{}{}><(){}>}}}
(<<(([<[{<<[<(()[])>[{{}}([]<>)]][((()<>)<()<>>)<(<>){<>{}}>]>(<{[<>{}]<{}<>>}>)>}(([<<{<>[]}<<
{[[{{([({<{{({{}()}<()[]>)[(<>{}){[]{}}]}}<(<{<><>}({}<>)><[{}()]<<>[]>>)>>{{<(<<>[]><{}[]>)>}[[<[[]
[([{<<({<{<[<[[][]][{}{}]>({<><>})]<({<>{}})>><<<<<>[]>(()<>)>({()[]})>>}<([{<{}<>>{{}<>}}([<><>]{
{[{({(([<[((<{[]()}{{}()}>{<()[]>[<>{}]})([[()[]]][{()()}([]{})])){(<{[]{}}[{}()]>[{<>[]}{{}()}]
[{[{({[{{<(<<([]<>)[()[]]><<[]{}><<>{}>>>[([<>[]](()<>)}([{}{}](<>[]))])>[<(<[{}[]]><<<><>>[[]()]>)[{[()(
[{<[<[[{{<{{((<>{})<[]{}>)(<<>[]>({}[]))}[<([]())<<><>>><<()<>>({}())>]}{<{[<>{}]}{([][]){[][]}}>({<[]{}>
({<((<([{{[[(([])[[]])[[<>{}][[]]]][[[[][]}{{}<>}]([{}{}][()<>])]]{[<[[][]]({}())>{[{}<>][<><>]}]}}}
{<<{({[[({{{<(<>())(<>{})>(({}[])(<>{}))}<<{[]{}}<[]>>>}{{(<<>{}><{}{}>)(<()()><[]()>)}{[({}
<[{{([<[{[((<[(){}][<>[]]>(<{}()>[<>[]]})[[(<>){<>()}]])<(([[][]]<<>{}>)){<[<><>][<>[]]><({}())
([(([((<<<{([{[]{}}])<[{()()}(()[])]{[()<>][<><>]}>>><{{[(()())<{}<>>]}(([[][]](<>[])))}((([
[<(({{{(<({[[[()[]][()[]]]{[<><>]{[]<>}}>[([()()]([][]))[[{}{}]{[]{}}]]}{[[[<>][{}[]]]][{[<>()][()<
[<[<<(([{{<<[((){})[<>{}]]{<[]()>}><{(()[])}((()[])[(){}])>>}}(({{[({}[])<()[]>]{[[][]]}}{(<<><>>)([(){}
[{[[<(({{({[{<()<>>((){})}(({}{}))](<[()<>]({}{})><<<>{}>(<>())>)}{[<<<>()>{<><>}><(()[])<{}[]>>]))}<{[(
<([[{{(([<<<<({}())([][])>[[[]{}]{[]<>}]>[{{()[]}<()[]>)[{{}[]}<[][]>]]>{<<[(){}](<>[])>[[{}[]]]>(
[[[[({[{<{(<{[[]<>]<(){}>}([(){}>[{}{}])>[{[{}()]{(){}}}])}>}]<[<(<{[[[]()]<{}<>>](<[]><(){
{(<[({{<<(<{{{{}{}}}<{<><>}<{}{}>>}<[<{}{}><()[]>]([{}[]]{<><>})>>)>>{[[([{<<><>>{()()}}<<<
<[({<([{[{[({<{}{}><{}[]>})([<()()>{<><>}]([()[]]{{}[]})>]({<{()()}<[]()>>[{[]()}({}())]})
<(([{(<([([([(()())[(){}]](<[]{}>[<><>]))(({()<>}<<>()>)(<{}[]>({}[])))][{[[[][]]](<<><>>)}
<{{(<{<[{((((({})({}<>))(({}())(<>[]))){{{[][]}[(){}]}<({}<>)<{}<>>>})){<({[{}()]<[]<>>}((()[])(<>{
{({({{{<((<{<{()[]}({}[])>{<{}<>>(()[])}}{([<>][[][]])}>)({({[<>()]<<>{}>}<[<>]([]{})>){([[]{
{[<((({<([<({[<>](<>)}((<>[]))){[[()()][<>]](([]){{}{}})}>])(<[[[[{}()]][({}<>){<><>}]]{<[
[<<<[(<<{({{<<()<>>({}{})><[<>[]]({}{})>}<{[(){}][(){}>}[[<>{}]{<>()}]>})[{[[[{}]<[]<>>][{(){}}]]<{[(
[{((<[{<({[{<[[]<>][{}[]]>}[(([][])<<>()>){<{}{}>[{}()]}]][[{{()[]}<[]{}>}(({}<>)<{}[]>)]{<<[]<>><()()>}}]})>
{[{{(<[{{{({{<{}{}><()>}[{[]()}{[]<>}]})}}[<{<[<{}()>[()[]]]<{{}<>}{[]}>>{(<{}{}><()()>)}}{{({[]()})([
{<{{({([[<(<[<[]{}>{{}()}]<({}{}){(){}}>><([()()]<(){}>){([]())(()[])}>){([([]<>)]<{<><>}[()<>]>){{<[]<>>[(
<[([(([[<[<[[<<>[]>[[]<>]]]<({[]<>}{<>{}})<[(){}]<[]<>>>>>[(<([]())>)[{[(){}](<>{})}<<[]<>>{<
{<[(<<[{<(<<{({}{})[(){}]}{[{}[]]{[]()}}>{<<<>{}>{[]{}}>}>[<(<{}<>>){<(){}><{}<>>}>(<{<><>}{{}{}}><((){})
([(<[(({{({[<([][])[(){}]>{[[]()]}]<[{[][]}{{}[]}](<[]<>>{{}{}])>})}}({[([{(()())[[][]]}<((){})
{[<[(<<{([({{<{}[]>(<>)}<(<>())<<><>>>}{(([]<>){<>()})})((({<>}<<>[]>)[([]()){{}()}]){<{<>()}>})](<<<[{}[
<((<[{[[[<<(<{()[]}(()[])>((<><>)[{}{}])){(<<>()>{[][]})[<[]{}><()[]>]}>[{<<()[]>([][])><{[]{}}
[{{({[<<{[<<{(()()){{}{}}}<[{}[]]{[]{}}>>>({({(){}}[<><>])({{}{}}<{}()>)}[{({}<>)<{}()>}])](([({()
<(({([<[{(([(({}[])([]()))<<()<>>{[]<>})]<<<[][]>>(<{}<>><[]<>>)>){<[{<>}[<>[]]]{<{}<>>{[]<>}}>[<[<>[]][<>
([{<<[[[[([[<[[]]{<>[]}>{(()[])<(){}>}]<[<()[]>(<>())]({[]()}[[]()])>]<{<{()<>}<()[]>><<<>>{{}{}}>}>)
({{<<({(([<{(([][])[()[]])}[[[()<>](())])><[([{}()][{}<>])<[[]{}](()<>)>]>]{(<<((){})<(){}>>({
[(<([(<{{<[[[{{}<>}{<>{}}]({()<>}<()[]>)]{[<<>[]>[{}<>]]<[{}[]](()[])>}]>}<{<<{{{}[]}((){})}>}}<{<[{()()}[<
{<<[({[{{{[[{(()())({})}][<<<>{}>([]())>]][(([{}()]{()[]}))<({<>[]}[{}()])>]}[<(<<<><>>[[]{}]>)<<
<{{{(([[[(([<(()())({}<>)>({[]{}}{(){}})]({{()}<[]()>}([[]{}]{()[]})))({{{()[]}<[]<>>}<[<>()]<<>[]}>}[{<[][]>
[(<{<(([([<<<{[]()}<{}>>)<<{<>{}}{[]}>{<<>()>{{}<>}}>>][{<{[{}[]]}(<<>()>)>[{(<><>)({}<>)}<
[[<<<[({[[<<((<><>){<><>})[(<><>)[<>()]]>{<[{}]>}>]]}<{<([<{<>{}}<<>()>>({[]<>}{()()})]({<{}{}>{(){}}}>)>[[(<
{({[([{[[([<((()[])(()[]))<<{}()>{()()}>>({({}[])}[[<>()}<{}[]>])]<([{()<>}{<>()}]([()](<>{})))<<((
<[((([<[<({{(<<>()>[<>[]])(([]()){[]<>))}(({()[]}<(){}>)[[[]()]<<><>>])}{[{{{}<>}[<>{}]}][(([]<>)((){}))]}
((<<[[[{((<<([[]<>][<>{}])[{<>{}}(()[])]>([{(){}}{{}<>}][({}{})([]())])>)<[{{{(){}}<[]{}>}(<[]<>>({}<>))
[[[{({{[[<[<<<<><>>[[]<>]>[<[]<>><<>()>]>({{<>{}}})]{(<<<>{}>{{}{}}><(()[])[{}{}]>)}><<[{[()[]]{
{[[{([[<<[[[{[()[]]{<>()}}({<><>})]{((<>[])[<>()])}]<(([[][]]<()[]>)){<({}<>)(<>{}}>{(<>{})(<><>)}}>]{([{[<><
[([[<[<({[{(([()()]{{}[]})[([]())(()())])[{{[]()}[<>{}]}({{}[]}[<>()])]}]<([<({}[]){[]()}>(<()()>[()<>])][(
<(<({{<(([[([[<>()]((){})]{(<>){<>[]}})[((<><>)({}{}))]]([<[{}[]]{[]<>}]][{<(){}><[]<>>}<[{}[
{[[({<[[{[({<([][]){<>()}>}(<(()()){()<>}>{<<>{}>}))<{<<()[]><{}<>>><({}<>)({}())>}((({}{})
(<(<({<<(<{[[<<>[]>({}{})][<[]()>{()()}]]}({{{<>[]}[<>{}]}({(){}}<()[]>)}}>)>{{{[({[[]()][[]{}]}(<<>[]>)){
({{{<(({[{{{{[{}<>][()<>]}<{()<>}>}[[({}())<[]()>][[<>[]]({}())]]}[[([{}()]({}{}))<([]())>]<{<{}[]>
[{([({<{(<[({{()()}(()<>)}(({}<>)<[]{}>)){([[][]]<(){}>)}]<<<<<>()><{}<>>>[((){})[[]{}]]><{<[]{}>>>>>)[(
{[(<({[<{<{{<{<>()}({}[])>(<{}[]>[<>()])}[[<[]<>>({})]{<<>{}><()[]>}]}>}[{{<{([]())[()()]}([[][]][
{[{{{{<<<{<(([[][]]){{[]{}}({}{})})[([()()]{[]()}){([]{})<{}[]>}]>[<(<[][]>{[]<>})[{{}()}(<>(
<[({{([[([{({{{}{}}<{}[]>}([(){}][<>{}]))}<{<[<>[]][[]<>]>[([][])]}([(<>{})[[][]]])>][{[{([]{})[[]<
<{{{<(([({{({<{}<>>[()()]}(([]){{}}))}}[(({{[]()}<{}<>>}[{[][]}<[]{}>])[<[()()](()())><(()){<>{}}>])[{<{[]<>}
{(<[{{[((<[[[[()()]([][])]([<>{}][<>()])]]>))<{(<<<([]{}){(){}}><<{}>{[][]}>>>{{(<<>>[(){}])<[<>()]{
{[{({{(<{({<({<>}<[][]>)([[]{}]{[][]})>[{(()())(()<>)}]][<[<()[]><{}{}>]({<>[]}<{}[]>)>[{<{}{}>[{}{
[{<{<({<<{[<((()<>)[{}()]){(<><>)<()<>>}>{(([]<>)[[]<>])<{()}[<><>]>}]}({[{{{}<>}({}())>(<{}<>>{{}()})][<
((<[{[[<[<(([(()[])<[]{}>](({}<>){<>[]}))<((()[])({}())){{()[]}[()<>]}>)[[((<>[])[<>()])[{{}<>}[{}{}]]]]><
[{<({{(([([[<<()()><<><>>>[<()[]>([]<>)]]{[{()<>}]((()[]){{}{}})}])[({[([]<>)][[<>[]]<{}{}>]}{[[[]
(<{(([{{<[([[<()<>>(<>)]<([])[(){}]>]){{[<[]<>>{{}{}}]}({[{}]}[{()[]}{{}<>}])}]>{<<{{<(){}>({}{}
({{(<{{[[<{<[{{}{}}{<>[]}][(<>{}>(()<>)]>}[{<{{}<>}><{()<>}<[]()>>}]>({[{{{}{}}<{}{}>}(((){})[[]<>])]({<[][]>"


IO.inspect(AOC10.solve_2(input))
