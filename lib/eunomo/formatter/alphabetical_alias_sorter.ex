defmodule Eunomo.Formatter.AlphabeticalAliasSorter do
  @moduledoc """
  Sorts `alias` definitions alphabetically.

  The sorting does not happen globally. Instead each "alias block" is sorted separately. An "alias
  block" is a set of `alias` expressions that are _not_ separated by at least one empty newline or
  other non-alias expressions.

  Only the order of lines is modified by this formatter. Neither the overall number of lines nor
  the content of a single line will change. This means that multi-aliases are not internally
  sorted i.e. `Hello.{World, Earth}` does _not_ become `Hello.{Earth, World}`.

  ## Examples

      iex> code_snippet = \"\"\"
      ...> alias Eunomo.Z.{L, I}
      ...> alias Eunomo.Z
      ...> alias __MODULE__.B
      ...> alias __MODULE__.A
      ...> alias Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> alias Eunomo.C
      ...> \\nalias Eunomo.PG.Repo
      ...> alias A
      ...> alias Eunomo.Patient
      ...> \"\"\"
      ...> Eunomo.format_string(code_snippet, [Eunomo.Formatter.AlphabeticalAliasSorter])
      \"\"\"
      alias __MODULE__.A
      alias __MODULE__.B
      alias Eunomo.C
      alias Eunomo.Z
      alias Eunomo.Z.{L, I}
      alias Eunomo.{
        L,
        B,
        # test
      }
      \\nalias A
      alias Eunomo.Patient
      alias Eunomo.PG.Repo
      \"\"\"

  """

  @behaviour Eunomo.Formatter

  alias Eunomo.Formatter.AlphabeticalExpressionSorter
  alias Eunomo.LineMap

  @impl true
  @spec format(LineMap.t()) :: LineMap.t()
  def format(line_map) when is_map(line_map) do
    AlphabeticalExpressionSorter.format(line_map, :alias)
  end
end
