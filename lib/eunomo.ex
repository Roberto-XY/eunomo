defmodule Eunomo do
  @moduledoc """
  Sorts `alias`, `import` and `require` definitions alphabetically.

  The sorting does not happen globally. Instead each "block" is sorted separately. An "block" is a
  set of expressions that are _not_ separated by at least one empty newline or other
  non-(alias,import,require) expressions. Note that the file is first formatter by the default
  Elixir code formatter!

  Only the order of lines is modified by this formatter. Neither the overall number of lines nor the
  content of a single line will change.

  Besides the options `Code.format_string!/2` and `Mix.Tasks.Format`, the `.formatter.exs` file
  supports the following Eunomo specific options:

    * `:eunomo_opts` (a keyword list) - toggles expressions to be sorted. Available switches:
        * `sort_alias: :boolean`
        * `sort_import: :boolean`
        * `sort_require: :boolean`

      By default all are `false` & the behavior is identical to the default formatter.

  A complete `my_app`'s `.formatter.exs` would look like this:

      # my_app/.formatter.exs
      [
        plugins: [Eunomo],
        eunomo_opts: [
          sort_alias: true,
          sort_import: true,
          sort_require: true
        ],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]

  ## Examples

  Sorting only alias expressions:
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
      ...> \"\"\"
      ...> Eunomo.format(code_snippet, [eunomo_opts: [sort_alias: true]])
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
      \"\"\"

  Sorting only import expressions:
      iex> code_snippet = \"\"\"
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
      ...> \"\"\"
      ...> Eunomo.format(code_snippet, [eunomo_opts: [sort_import: true]])
      \"\"\"
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
      \"\"\"


  Sorting only require expressions:
      iex> code_snippet = \"\"\"
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
      ...> Eunomo.format(code_snippet, [eunomo_opts: [sort_require: true]])
      \"\"\"
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
  def format(content, opts) do
    content
    # Elixir formatter plugin system checks if a file matches a plugin file extension and then
    # dispatches to a matching formatter. In current main (>1.14.1) that is already expanded by
    # allowing multiple formatters formatting the same file extension after each other
    # (https://github.com/elixir-lang/elixir/pull/12032). But .ex and .exs files do not allow this,
    # hence we have to explicitly call the Elixir formatter here.
    # FIXME: Ask upstream if this should change
    |> elixir_format(opts)
    |> eunomo_format(opts)
  end

  defp eunomo_format(content, opts) do
    eunomo_opts = Keyword.get(opts, :eunomo_opts, [])
    sort_alias? = Keyword.get(eunomo_opts, :sort_alias, false)
    sort_import? = Keyword.get(eunomo_opts, :sort_import, false)
    sort_require? = Keyword.get(eunomo_opts, :sort_require, false)

    line_map = LineMap.from_code_string(content)

    line_map =
      if sort_alias? do
        ExpressionSorter.format(line_map, :alias)
      else
        line_map
      end

    line_map =
      if sort_import? do
        ExpressionSorter.format(line_map, :import)
      else
        line_map
      end

    line_map =
      if sort_require? do
        ExpressionSorter.format(line_map, :require)
      else
        line_map
      end

    LineMap.to_code_string(line_map)
  end

  # Copied from Mix.Tasks.Format since it is private
  defp elixir_format(content, formatter_opts) do
    case Code.format_string!(content, formatter_opts) do
      [] -> ""
      formatted_content -> IO.iodata_to_binary([formatted_content, ?\n])
    end
  end
end
