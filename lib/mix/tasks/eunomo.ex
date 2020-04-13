defmodule Mix.Tasks.Eunomo do
  @moduledoc """
  Formats the given files/patterns.

  The default Elixir formatter has the philosophy of not modifying non metadata parts of the AST.
  `Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the
  default formatter. As of now the use case is to sort `import` and `alias` definitions
  alphabetically.

  To make usage more seamless it is recommended to define an alias in `mix.exs`. For example:

  ```elixir
  def project do
    [
      ...,
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      format!: ["format", "eunomo"]
    ]
  end
  ```

  Now `mix format!` will run the standard Elixir formatter as well as Eunomo.

  ## Options

  Eunomo will read the `.eunomo.exs` file in the current directory for formatter configuration.

    - `:inputs` - List of paths and patterns to be formatted. By default the atom
      `:read_from_dot_formatter` is passed which will read all `:inputs` from `.formatter.exs`.

    - `:formatter` - List of modules that implement the `Eunomo.Formatter` behaviour. They are
      applied sequentially to all matched files.

  ## Task-specific options

    - `--check-formatted` - checks that the file is already formatted. This is useful in
      pre-commit hooks and CI scripts if you want to reject contributions with unformatted code.

    - `--dry-run` - does not save files after formatting.

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
    |> Enum.reduce({[], []}, &collect_status/2)
    |> check!()
  end

  @spec expand_relative_to_cwd(Path.t()) :: Path.t()
  defp expand_relative_to_cwd(path) do
    case File.cwd() do
      {:ok, cwd} -> Path.expand(path, cwd)
      _ -> path
    end
  end

  @spec collect_status({:ok, tuple}, {[tuple], [tuple]}) :: {[tuple], [tuple]}
  defp collect_status({:ok, :ok}, acc), do: acc

  defp collect_status({:ok, {:exit, _, _, _} = exit}, {exits, not_formatted}) do
    {[exit | exits], not_formatted}
  end

  defp collect_status({:ok, {:not_formatted_by_eunomo, file}}, {exits, not_formatted}) do
    {exits, [file | not_formatted]}
  end

  @spec check!({[tuple], [tuple]}) :: :ok
  defp check!({[], []}) do
    :ok
  end

  defp check!({[{:exit, :stdin, exception, stacktrace} | _], _not_formatted}) do
    Mix.shell().error("mix format failed for stdin")
    reraise exception, stacktrace
  end

  defp check!({[{:exit, file, exception, stacktrace} | _], _not_formatted}) do
    Mix.shell().error("mix format failed for file: #{Path.relative_to_cwd(file)}")
    reraise exception, stacktrace
  end

  defp check!({_exits, [_ | _] = not_formatted}) do
    Mix.raise("""
    mix format failed due to --check-formatted.
    The following files were not formatted:
    #{to_bullet_list(not_formatted)}
    """)
  end

  @spec to_bullet_list([Path.t()]) :: String.t()
  defp to_bullet_list(files) do
    Enum.map_join(files, "\n", &"  * #{&1 |> to_string() |> Path.relative_to_cwd()}")
  end
end
