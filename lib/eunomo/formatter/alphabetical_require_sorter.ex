defmodule Eunomo.Formatter.AlphabeticalRequireSorter do
  @moduledoc """
  Sorts `require` definitions alphabetically.

  The sorting does not happen globally. Instead each "require block" is sorted separately. An "require
  block" is a set of `require` expressions that are _not_ separated by at least one empty newline or
  other non-require expressions.

  Only the order of lines is modified by this formatter. Neither the overall number of lines nor
  the content of a single line will change. This means that multi-requires are not internally
  sorted i.e. `Hello.{World, Earth}` does _not_ become `Hello.{Earth, World}`.

  ## Examples

      iex> code_snippet = \"\"\"
      ...> require Eunomo.Z.{L, I}
      ...> require Eunomo.Z
      ...> require Eunomo.{
      ...>   L,
      ...>   B,
      ...>   # test
      ...> }
      ...> require Eunomo.C
      ...> \\nrequire Eunomo.PG.Repo
      ...> require A
      ...> require Eunomo.Patient
      ...> \"\"\"
      ...> Eunomo.format_string(code_snippet, [Eunomo.Formatter.AlphabeticalRequireSorter])
      \"\"\"
      require Eunomo.C
      require Eunomo.Z
      require Eunomo.Z.{L, I}
      require Eunomo.{
        L,
        B,
        # test
      }
      \\nrequire A
      require Eunomo.Patient
      require Eunomo.PG.Repo
      \"\"\"

  """

  @behaviour Eunomo.Formatter

  alias Eunomo.Formatter.AlphabeticalExpressionSorter
  alias Eunomo.LineMap

  @impl true
  @spec format(LineMap.t()) :: LineMap.t()
  def format(line_map) when is_map(line_map) do
    AlphabeticalExpressionSorter.format(line_map, :require)
  end
end
