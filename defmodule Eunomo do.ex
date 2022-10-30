defmodule Eunomo do
  @moduledoc """
  Sorts `alias`, `import` and `require` definitions alphabetically.

  The sorting does not happen globally. Instead each "block" is sorted separately. An "block" is a
  set of expressions that are _not_ separated by at least one empty newline or other
  non-(alias,import,require) expressions. Note that the file is first formatter by the default
  Elixir code formatter!

  Only the order of lines is modified by this formatter. Neither the overall number of lines nor the
  content of a single line will change.

  See `Code.format_string!/2` and `Mix.Tasks.Format` for supported configuration.

  ## Examples

      iex> code_snippet = \"\"\"
      ...> alias Eunomo.Z.{L, I}
      ...> alias Eunomo.Z
      ...> alias __MODULE__.B
      ...> alias __MODULE__.A
      ...> alias Eunomo.C
      ...> alias Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> \\nalias Eunomo.PG.Repo
      ...> alias A
      ...> alias Eunomo.Patient
      ...> import Eunomo.Z.{L, I}
      ...> import Eunomo.Z, only: [hello_world: 0]
      ...> import B, expect: [callback: 1]
      ...> import Eunomo.C
      ...> import Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> \\nimport Eunomo.PG.Repo
      ...> import A
      ...> import Eunomo.Patient
      ...> require Eunomo.Z.{L, I}
      ...> require Eunomo.Z
      ...> require Eunomo.C
      ...> require Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> \\nrequire Eunomo.PG.Repo
      ...> require A
      ...> require Eunomo.Patient
      ...> \"\"\"
      ...> Eunomo.format(code_snippet)
      \"\"\"
      alias __MODULE__.A
      alias __MODULE__.B
      alias Eunomo.C
      alias Eunomo.Z
      alias Eunomo.Z.{L, I}
      \\nalias Eunomo.{
        L,
        B
        # test
      }
      \\nalias A
      alias Eunomo.Patient
      alias Eunomo.PG.Repo
      import B, expect: [callback: 1]
      import Eunomo.C
      import Eunomo.Z, only: [hello_world: 0]
      import Eunomo.Z.{L, I}
      \\nimport Eunomo.{
        L,
        B
        # test
      }
      \\nimport A
      import Eunomo.Patient
      import Eunomo.PG.Repo
      require Eunomo.C
      require Eunomo.Z
      require Eunomo.Z.{L, I}
      \\nrequire Eunomo.{
        L,
        B
        # test
      }
      \\nrequire A
      require Eunomo.Patient
      require Eunomo.PG.Repo
      \"\"\"

  """

  @behaviour Mix.Tasks.Format

  alias Eunomo.ExpressionSorter
  alias Eunomo.LineMap

  @impl true
  @spec features(Keyword.t()) :: [sigils: [atom()], extensions: [binary()]]
  def features(_opts) do
    [extensions: [".ex", ".exs"]]
  end

  @impl true
  @spec format(String.t(), Keyword.t()) :: String.t()
  def format(content, opts \\ []) do
    content
    # Elixir formatter plugin system checks if a file matches an plugin file extension and then
    # dispatches to a matching formatter. In current main (>1.14.1) that is already expanded by
    # allowing multiple formatters formatting the same file extension after each other
    # (https://github.com/elixir-lang/elixir/pull/12032). But .ex and .exs files do not allow this,
    # they dispatch to a single formatter or the user would have to register the default formatter
    # as a plugin explicitly. Hence we have to explicitly call the Elixir formatter here.
    # FIXME: Ask upstream if this should change
    |> elixir_format(opts)
    |> eunomo_format()
  end

  defp eunomo_format(content) do
    LineMap.from_code_string(content)
    |> ExpressionSorter.format(:alias)
    |> ExpressionSorter.format(:import)
    |> ExpressionSorter.format(:require)
    |> LineMap.to_code_string()
  end

  # Copied from Mix.Tasks.Format since it is private
  defp elixir_format(content, formatter_opts) do
    case Code.format_string!(content, formatter_opts) do
      [] -> ""
      formatted_content -> IO.iodata_to_binary([formatted_content, ?\n])
    end
  end
end
