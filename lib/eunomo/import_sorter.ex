defmodule Eunomo.ImportSorter do
  @moduledoc """
  Sorts `import` definitions alphabetically.

  The sorting does not happen globally. Instead each "import block" is sorted separately. An
  "import block" is a set of `import` expressions that are _not_ separated by at least one empty
  newline or other non-import expressions.

  Only the order of lines is modified by this formatter. Neither the overall number of lines nor
  the content of a single line will change.

  ## Examples

      iex> code_snippet = \"\"\"
      ...> import Eunomo.Z.{L, I}
      ...> import Eunomo.Z, only: [hello_world: 0]
      ...> import Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> import Eunomo.C
      ...> import B, expect: [callback: 1]
      ...> \\nimport Eunomo.PG.Repo
      ...> import A
      ...> import Eunomo.Patient
      ...> \"\"\"
      ...> Eunomo.ImportSorter.format(code_snippet, [])
      \"\"\"
      import B, expect: [callback: 1]
      import Eunomo.C
      import Eunomo.Z, only: [hello_world: 0]
      import Eunomo.Z.{L, I}
      import Eunomo.{
        L,
        B,
        # test
      }
      \\nimport A
      import Eunomo.Patient
      import Eunomo.PG.Repo
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
  def format(contents, _opts) do
    contents
    |> LineMap.from_code_string()
    |> ExpressionSorter.format(:import)
    |> LineMap.to_code_string()
  end
end
