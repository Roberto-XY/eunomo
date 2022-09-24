defmodule Eunomo.RequireSorter do
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
      ...> Eunomo.RequireSorter.format(code_snippet, [])
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
    |> ExpressionSorter.format(:require)
    |> LineMap.to_code_string()
  end
end
