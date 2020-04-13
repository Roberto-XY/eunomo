defmodule Eunomo.Formatter.AlphabeticalImportSorter do
  @moduledoc """
  Sorts `import` definitions alphabetically.

  The sorting does not happen globally. Instead each "import block" is sorted separately. An
  "import import" is a set of `import` expressions that are _not_ separated by at least one empty
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
      ...> \\nimport A
      ...> \"\"\"
      ...> Eunomo.format_string(code_snippet, [Eunomo.Formatter.AlphabeticalImportSorter])
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
      \"\"\"

  """

  @behaviour Eunomo.Formatter

  alias Eunomo.Formatter.AlphabeticalExpressionSorter
  alias Eunomo.LineMap

  @impl true
  @spec format(LineMap.t()) :: LineMap.t()
  def format(line_map) when is_map(line_map) do
    AlphabeticalExpressionSorter.format(line_map, :import)
  end
end
