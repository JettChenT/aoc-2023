defmodule ProblemOne do
  defp proc_line!(line) do
    aggr =
      line
      |> String.split(": ")
      |> List.last()
      |> String.split("; ")
      |> Enum.map(
        &(&1
          |> String.split(", ")
          |> Enum.map(fn t ->
            [num_st | [col | _]] = String.split(t, " ")
            num = String.to_integer(num_st)
            %{col => num}
          end)
          |> Enum.reduce(
            %{"red" => 0, "blue" => 0, "green" => 0},
            fn map, acc ->
              Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
            end
          ))
      )
      |> Enum.reduce(
        %{"red" => 0, "blue" => 0, "green" => 0},
        fn map, acc ->
          Map.merge(acc, map, fn _k, v1, v2 -> max(v1, v2) end)
        end
      )

    %{"red" => r, "blue" => b, "green" => g} = aggr
    r * g * b
  end

  def run do
    file_path = "input.txt"

    res =
      File.read!(file_path)
      |> String.split("\n")
      |> Enum.map(&proc_line!(&1))
      |> Enum.sum()

    IO.puts(res)
  end
end

ProblemOne.run()
