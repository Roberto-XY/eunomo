defmodule Mix.Tasks.Format.Eunomo do
  @moduledoc """
  Eunomo Adapter to be compatible with the Mix Format interface.
  
  ## Usage
  
  ```elixir
  # .formatter.exs
  [
    # Add Eunomo to your formatter plugins
    plugins: [Mix.Tasks.Format.Eunomo]
  ]
  ```
  """

  @behaviour Mix.Tasks.Format

  def features(_opts) do
    [extensions: [".ex", ".exs"]]
  end

  def format(contents, _opts) do
    contents
    |> Eunomo.format_string([
      Eunomo.Formatter.AlphabeticalAliasSorter,
      Eunomo.Formatter.AlphabeticalImportSorter,
      Eunomo.Formatter.AlphabeticalRequireSorter
    ])
  end
end
