defmodule Eunomo.LineMap do
  @moduledoc false

  # Super simple text abstraction. Maps a line_number to an iodata chunk.
  # Possibly to naive for complex transformations -
  # just right for `alias`, `import` and `require sorting.
  # Performance was not a design consideration.

  @type line_number :: non_neg_integer

  @typedoc """
  Invariant that should hold: sorted_key_set == 1..length(line_map) so that the `Eunomo.LineMap` is total
  i.e. every line number is present.
  """
  @type t :: %{optional(line_number) => iodata}

  @spec from_code_string(binary) :: t
  def from_code_string(code_string) when is_binary(code_string) do
    code_string
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.map(fn {line, index} -> {index, line} end)
    |> Enum.into(%{})
  end

  @spec to_code_string(t) :: String.t()
  def to_code_string(line_map) when is_map(line_map) do
    line_map
    |> Enum.sort_by(fn {line_number, _line} -> line_number end)
    |> Enum.intersperse("\n")
    |> Enum.reduce([], fn
      {_line_number, line}, acc -> [acc, line]
      "\n", acc -> [acc, "\n"]
    end)
    |> IO.iodata_to_binary()
  end

  @spec to_quoted(t) :: Macro.t()
  def to_quoted(line_map) when is_map(line_map) do
    line_map
    |> to_code_string()
    |> Code.string_to_quoted!(columns: true, token_metadata: true)
  end
end
