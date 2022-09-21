defmodule Eunomo.ExpressionSorter do
  @moduledoc false

  # Sorts expressions alphabetically.
  # This module is only meant to be used for alias, import & require expressions!

  alias Eunomo.LineMap

  defmodule LineModificationConflict do
    @moduledoc false

    defexception message: """
                   Please report a bug.
                   Same line got mapped twice in `Eunomo.ExpressionSorter`.
                 """
  end

  @spec format(LineMap.t(), atom) :: LineMap.t()
  def format(line_map, expression_atom) when is_map(line_map) and is_atom(expression_atom) do
    {_, res} =
      line_map
      |> LineMap.to_quoted()
      |> Macro.postwalk(%{}, fn
        {:__block__, _, _} = triple, acc ->
          acc =
            Map.merge(
              acc,
              ast_block_to_modifications(triple, expression_atom),
              fn _, _, _ -> raise LineModificationConflict end
            )

          {triple, acc}

        triple, acc ->
          {triple, acc}
      end)

    line_map
    |> Enum.map(fn {line_number, line} ->
      line_number = Map.get(res, line_number, line_number)
      {line_number, line}
    end)
    |> Enum.into(%{})
  end

  # Splits into expression blocks
  # - separated by a new line
  # - separated by a non "split" expression
  @spec split_into_expression_blocks([Macro.t()], atom) :: [Macro.t()]
  defp split_into_expression_blocks(args, split_expression) do
    %{expression_blocks: expression_blocks, current: current} =
      Enum.reduce(args, %{expression_blocks: [], current: []}, fn
        {^split_expression, [{:end_of_expression, [{:newlines, newline} | _]} | _], _} = element,
        acc ->
          if newline > 1 do
            %{expression_blocks: [[element | acc.current] | acc.expression_blocks], current: []}
          else
            %{expression_blocks: acc.expression_blocks, current: [element | acc.current]}
          end

        {^split_expression, _, _} = element, acc ->
          %{expression_blocks: acc.expression_blocks, current: [element | acc.current]}

        _, %{current: []} = acc ->
          acc

        _, acc ->
          %{expression_blocks: [acc.current | acc.expression_blocks], current: []}
      end)

    [current | expression_blocks]
  end

  @typep modifications :: %{optional(LineMap.line_number()) => LineMap.line_number()}

  @spec ast_block_to_modifications({:__block__, Macro.metadata(), [Macro.t()]}, atom) ::
          modifications()
  defp ast_block_to_modifications({:__block__, _, args}, split_expression) do
    args
    |> split_into_expression_blocks(split_expression)
    |> Enum.map(&Enum.sort_by(&1, fn t -> t |> Macro.to_string() |> String.downcase() end))
    |> accumulate_modifications(split_expression)
  end

  # Takes all sorted expression blocks and transforms them into concrete line changes.
  @spec accumulate_modifications([Macro.t()], atom) :: modifications
  defp accumulate_modifications(expression_blocks, split_expression) do
    Enum.reduce(expression_blocks, %{}, fn expression_block, acc ->
      first_line =
        expression_block
        |> Enum.map(fn {^split_expression, meta, _} ->
          Keyword.fetch!(meta, :line)
        end)
        |> Enum.min(fn -> 0 end)

      inner_acc = expression_block_to_modification(expression_block, first_line, split_expression)

      Map.merge(acc, inner_acc, fn _, _, _ -> raise LineModificationConflict end)
    end)
  end

  # Takes a sorted expression block and moves it to the `start_line`. The `start_line` == the
  # original start of the block. So only lines _within_ a block are shuffled but the blocks them
  # selves remain static in the file layout.
  @spec expression_block_to_modification(Macro.t(), non_neg_integer, atom) :: modifications
  defp expression_block_to_modification(expression_block, start_line, split_expression) do
    {acc, _} =
      Enum.reduce(expression_block, {%{}, start_line}, fn {^split_expression, meta, _},
                                                          {acc, current_line} ->
        from = Keyword.fetch!(meta, :line)
        to = meta |> Keyword.get(:end_of_expression, line: from) |> Keyword.fetch!(:line)

        {inner_acc, current_line} = range_to_modification(from..to, current_line)

        acc = Map.merge(acc, inner_acc, fn _, _, _ -> raise LineModificationConflict end)

        {acc, current_line}
      end)

    acc
  end

  # Takes a range and a start line and creates a mapping from each line in the range to start
  # line. e.g. 2..3, 5 -> %{2 => 5, 3 => 6} & the last new line number
  @spec range_to_modification(Range.t(), non_neg_integer) ::
          {modifications, LineMap.line_number()}
  defp range_to_modification(block_range, start_line) do
    Enum.reduce(block_range, {%{}, start_line}, fn old_line_number, {acc, new_line_number} ->
      acc = Map.put(acc, old_line_number, new_line_number)

      {acc, new_line_number + 1}
    end)
  end
end
