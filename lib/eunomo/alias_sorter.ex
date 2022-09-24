defmodule Eunomo.AliasSorter do
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
      ...> Eunomo.AliasSorter.format(code_snippet, [])
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
    |> ExpressionSorter.format(:alias)
    |> LineMap.to_code_string()
  end
end
