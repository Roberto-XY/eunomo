defmodule Eunomo do
  @moduledoc false

  alias Eunomo.Formatter
  alias Eunomo.LineMap

  @doc """
  Applies the given `Eunomo.Formatter`s to the file.

  See `Mix.Tasks.Eunomo` for opts.
  """
  @spec format_file(Path.t(), [module], Keyword.t()) ::
          :ok | {:exit, Path.t(), Exception.t(), any}
  def format_file(path, formatters, opts \\ [])
      when is_binary(path) and is_list(formatters) and is_list(opts) do
    input = File.read!(path)

    output = format_string(input, formatters, opts)

    check_formatted? = Keyword.get(opts, :check_formatted, false)
    dry_run? = Keyword.get(opts, :dry_run, false)

    cond do
      check_formatted? ->
        if input == output, do: :ok, else: {:not_formatted_by_eunomo, path}

      dry_run? ->
        :ok

      input == output ->
        :ok

      true ->
        File.write!(path, output)
    end
  rescue
    exception ->
      {:exit, path, exception, __STACKTRACE__}
  end

  @doc """
  Applies the given `Eunomo.Formatter`s to the file.

  See `Mix.Tasks.Eunomo` for opts.
  """
  @spec format_string(String.t(), [module], Keyword.t()) :: String.t()
  def format_string(input, formatters, opts \\ [])
      when is_binary(input) and is_list(formatters) and is_list(opts) do
    input
    |> LineMap.from_code_string()
    |> Formatter.format(formatters)
    |> LineMap.to_code_string()
  end
end
