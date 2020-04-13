defmodule Eunomo do
  @moduledoc """
  Documentation for `Eunomo`.

  The default Elixir formatter has the philosophy of never modifying non metadata parts of the
  AST. `Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the
  default formatter. As of now the use case is to sort `import` and `alias` definitions
  alphabetically.
  """

  alias Eunomo.Formatter
  alias Eunomo.LineMap

  @doc """

  """
  @spec format_file(Path.t(), [module], Keyword.t()) ::
          :ok | {:exit, Path.t(), Exception.t(), any}
  def format_file(path, formatters, opts \\ [])
      when is_binary(path) and is_list(formatters) and is_list(opts) do
    input = File.read!(path)

    output =
      input
      |> LineMap.from_code_string()
      |> Formatter.format(formatters)
      |> LineMap.to_code_string()

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

  @spec format_string(String.t(), [module], Keyword.t()) :: String.t()
  def format_string(input, formatters, opts \\ [])
      when is_binary(input) and is_list(formatters) and is_list(opts) do
    input
    |> LineMap.from_code_string()
    |> Formatter.format(formatters)
    |> LineMap.to_code_string()
  end
end
