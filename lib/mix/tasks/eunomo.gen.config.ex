defmodule Mix.Tasks.Eunomo.Gen.Config do
  use Mix.Task

  @config_filename ".eunomo.exs"
  @generated_file """
  # Used by "mix eunomo" with Elixir `< 1.13.0`
  [
    inputs: :read_from_dot_formatter,
    formatter: [
      Eunomo.AliasSorter,
      Eunomo.ImportSorter,
      Eunomo.RequireSorter
    ]
  ]
  """
  @shortdoc "Generates the default configuration. NOTE: Usage only recommended for Elixir version `< 1.13.0`!"

  @moduledoc """
  #{@shortdoc}

  For `>= 1.13.0` the formatter comes with a [plugin
  system](https://hexdocs.pm/mix/1.13.0/Mix.Tasks.Format.html#module-plugins). You should use that
  instead, see the `.formatter.exs` file in this repo for an example usage.

  The `#{@config_filename}` file is created in the current working directory. If it already exists
  the task is aborted.

  ```elixir
  #{@generated_file}
  ```
  """

  @impl true
  @spec run(command_line_args :: [binary]) :: :ok
  def run(_args) do
    create_config_file()
  end

  @spec create_config_file() :: :ok
  defp create_config_file do
    if File.exists?(@config_filename) do
      [:red, :bright, "File exists: #{@config_filename}, aborted."]
      |> IO.ANSI.format()
      |> IO.puts()
    else
      [:green, "* creating ", :reset, "#{@config_filename}"]
      |> IO.ANSI.format()
      |> IO.puts()

      File.write!(
        Path.join(File.cwd!(), @config_filename),
        @generated_file
      )
    end
  end
end
