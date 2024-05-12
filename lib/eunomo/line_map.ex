defmodule Eunomo.LineMap do
  @moduledoc false

  # Super simple text abstraction. Maps a line_number to an iodata chunk. Possibly too naive for
  # complex transformations - just right for `alias`, `import` and `require sorting. Performance
  # was not a design consideration.

  @type line_number :: non_neg_integer

  @typedoc """
  Invariant that should hold: sorted_key_set == 1..length(line_map) so that the `Eunomo.LineMap`
  is total i.e. every line number is present.
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

  @spec comments(t) :: t
  def comments(line_map) when is_map(line_map) do
    line_map
    |> Map.filter(fn {_, line} ->
      line
      |> String.trim()
      |> String.starts_with?("#")
    end)
  end

  @spec new_lines(t) :: t
  def new_lines(line_map) when is_map(line_map) do
    Map.filter(line_map, fn {_, line} -> String.trim(line) == "" end)
  end

  @spec get_continuous_block_backwards(t, line_number) :: t
  def get_continuous_block_backwards(line_map, n) do
    do_get_continuous_block_backwards(line_map, n)
  end

  @spec do_get_continuous_block_backwards(t, line_number, t) :: t
  defp do_get_continuous_block_backwards(line_map, n, acc \\ %{}) do
    if Map.has_key?(line_map, n) do
      new_acc = Map.put(acc, n, Map.fetch!(line_map, n))
      do_get_continuous_block_backwards(line_map, n - 1, new_acc)
    else
      acc
    end
  end

  @spec get_continuous_block_forwards(t, line_number, iodata) :: t
  def get_continuous_block_forwards(line_map, n, stop_on) do
    do_get_continuous_block_forwards(line_map, n, stop_on)
  end

  @spec do_get_continuous_block_forwards(t, line_number, iodata, t) :: t
  defp do_get_continuous_block_forwards(line_map, n, stop_on, acc \\ %{}) do
    if Map.has_key?(line_map, n) do
      elem = Map.fetch!(line_map, n)
      new_acc = Map.put(acc, n, elem)

      if elem == stop_on do
        new_acc
      else
        do_get_continuous_block_forwards(line_map, n + 1, stop_on, new_acc)
      end
    else
      acc
    end
  end
end
