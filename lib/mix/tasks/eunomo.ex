defmodule Mix.Tasks.Eunomo do
  @moduledoc """
  Formats the given files/patterns.
  """
  use Mix.Task

  @switches [
    check_formatted: :boolean,
    dry_run: :boolean
  ]

  @impl true
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: @switches)
    {dot_eunomo, _} = Code.eval_file(".eunomo.exs")

    inputs =
      if :read_from_dot_formatter == dot_eunomo[:inputs] do
        {dot_formatter, _} = Code.eval_file(".formatter.exs")
        dot_formatter[:inputs]
      else
        dot_eunomo[:inputs]
      end

    inputs
    |> List.wrap()
    |> Enum.flat_map(fn input ->
      input
      |> Path.wildcard(match_dot: true)
      |> Enum.map(&expand_relative_to_cwd/1)
    end)
    |> Task.async_stream(
      fn file ->
        Eunomo.format_file(file, dot_eunomo[:formatter], opts)
      end,
      ordered: false,
      timeout: 30_000
    )
    |> Enum.into([])
    |> IO.inspect()
  end

  defp expand_relative_to_cwd(path) do
    case File.cwd() do
      {:ok, cwd} -> Path.expand(path, cwd)
      _ -> path
    end
  end
end
