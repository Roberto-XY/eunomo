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
    comments = LineMap.comments(line_map)
    new_lines = LineMap.new_lines(line_map)
    new_lines_and_comments = Map.merge(comments, new_lines)

    {_, res} =
      line_map
      |> LineMap.to_quoted()
      |> Macro.postwalk(%{}, fn
        {:__block__, _, args} = triple, acc ->
          new_args =
            Enum.map(args, fn
              {atom, meta, args} = triple ->
                if Keyword.has_key?(meta, :line) do
                  prev_line_number = Keyword.fetch!(meta, :line) - 1

                  if Map.has_key?(comments, prev_line_number) do
                    comment_block =
                      LineMap.get_continuous_block_backwards(
                        comments,
                        prev_line_number
                      )

                    new_meta = Keyword.put_new(meta, :preceding_comments, comment_block)
                    {atom, new_meta, args}
                  else
                    triple
                  end
                else
                  triple
                end

              x ->
                x
            end)
            # We need to do this exercise with special new line handling since the default elixir AST
            # metadata is bugged in the sense that new line metadata is not correctly set in some cases.
            |> Enum.map(fn
              {atom, meta, args} = triple ->
                if Keyword.has_key?(meta, :end_of_expression) do
                  end_of_expression = Keyword.fetch!(meta, :end_of_expression)
                  next_line_number = Keyword.fetch!(end_of_expression, :line) + 1

                  if Map.has_key?(new_lines_and_comments, next_line_number) do
                    new_line_block =
                      LineMap.get_continuous_block_forwards(
                        new_lines_and_comments,
                        next_line_number,
                        _stop_on = ""
                      )

                    {_, last} = Enum.max_by(new_line_block, fn {key, _} -> key end)

                    if last == "" do
                      new_meta =
                        update_in(meta, [:end_of_expression, :newlines], fn _ ->
                          map_size(new_line_block) + 1
                        end)

                      {atom, new_meta, args}
                    else
                      triple
                    end
                  else
                    triple
                  end
                else
                  triple
                end

              x ->
                x
            end)

          acc =
            Map.merge(
              acc,
              ast_block_to_modifications(new_args, expression_atom),
              fn _, _, _ -> raise LineModificationConflict end
            )

          {triple, acc}

        triple, acc ->
          {triple, acc}
      end)

    mapped_values = Map.values(res) |> MapSet.new()

    if length(Map.values(res)) != MapSet.size(mapped_values) do
      raise LineModificationConflict
    end

    Enum.map(res, fn {old_line_n, new_line_n} ->
      {new_line_n, Map.fetch!(line_map, old_line_n)}
    end)
    |> Enum.into(%{})
    |> Map.merge(line_map, fn _k, new, _old -> new end)
  end

  @typep modifications :: %{optional(LineMap.line_number()) => LineMap.line_number()}

  @spec ast_block_to_modifications([Macro.t()], atom) :: modifications()
  defp ast_block_to_modifications(args, split_expression) do
    args
    |> split_into_expression_blocks(split_expression)
    |> Enum.map(&Enum.sort_by(&1, fn t -> t |> Macro.to_string() |> String.downcase() end))
    |> accumulate_modifications(split_expression)
  end

  # Splits into expression blocks
  # - separated by a new line
  # - separated by a non "split" expression
  @spec split_into_expression_blocks([Macro.t()], atom) :: [Macro.t()]
  defp split_into_expression_blocks(args, split_expression) do
    %{expression_blocks: expression_blocks, current: current} =
      Enum.reduce(args, %{expression_blocks: [], current: []}, fn
        {^split_expression, meta, _} = element, acc ->
          case {meta[:line], meta[:end_of_expression][:line], meta[:end_of_expression][:newlines]} do
            {start_line, end_line, new_lines}
            when end_line - start_line > 0 or new_lines > 1 ->
              %{
                expression_blocks: [[element | acc.current] | acc.expression_blocks],
                current: [],
                prev: element
              }

            _ ->
              %{
                expression_blocks: acc.expression_blocks,
                current: [element | acc.current]
              }
          end

        _, %{current: []} = acc ->
          acc

        _, acc ->
          %{expression_blocks: [acc.current | acc.expression_blocks], current: []}
      end)

    [current | expression_blocks]
  end

  # Takes all sorted expression blocks and transforms them into concrete line changes.
  @spec accumulate_modifications([Macro.t()], atom) :: modifications
  defp accumulate_modifications(expression_blocks, split_expression) do
    Enum.reduce(expression_blocks, %{}, fn expression_block, acc ->
      first_line =
        expression_block
        |> Enum.map(fn {^split_expression, meta, _} ->
          comment_line_count = map_size(Keyword.get(meta, :preceding_comments, %{}))
          Keyword.fetch!(meta, :line) - comment_line_count
        end)
        |> Enum.min(fn -> 0 end)

      inner_acc =
        expression_block_to_modification(expression_block, first_line, split_expression)

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
        comment_line_count = map_size(Keyword.get(meta, :preceding_comments, %{}))
        from = Keyword.fetch!(meta, :line) - comment_line_count
        to = Keyword.get(meta, :end_of_expression, line: from) |> Keyword.fetch!(:line)

        {inner_acc, current_line} =
          range_to_modification(from..to, current_line)

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
