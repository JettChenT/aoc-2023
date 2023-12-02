defmodule ProblemOne do
  defp proc_line!(line) do
    [game | [content | _ ]] = line |> String.split(": ")
    game_n = game |> String.split() |> List.last() |> String.to_integer()
    illegal = content
      |> String.split("; ")
      |> Enum.map(
        fn x ->
          gamesum = x
            |> String.split(", ")
            |> Enum.map(fn t ->
              [num_st | [col | _]] = String.split(t, " ")
              num = String.to_integer(num_st)
              %{col => num}
            end)
            |> Enum.reduce(
              %{"red"=>0, "blue"=>0, "green"=>0},
              fn map, acc ->
                Map.merge(acc, map, fn _k, v1, v2 -> v1+v2 end)
              end
            )
          %{"red" => r, "green"=>g, "blue"=>b} = gamesum
          r>12 or g>13 or b>14
        end
      )
      |> Enum.any?()
    unless illegal do game_n else 0 end
  end

  def run do
    file_path = "input.txt"
    res = File.read!(file_path)
      |> String.split("\n")
      |> Enum.map(& proc_line!(&1))
      |> Enum.sum()
    IO.puts(res)
  end
end

ProblemOne.run()
