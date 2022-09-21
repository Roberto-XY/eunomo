defmodule Eunomo do
  @moduledoc false

  @spec format_file(Path.t(), [module], Keyword.t()) ::
          :ok | {:exit, Path.t(), Exception.t(), any}
  def format_file(path, formatters, opts \\ [])
      when is_binary(path) and is_list(formatters) and is_list(opts) do
    input = File.read!(path)

    output = format(input, formatters)

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

  @spec format(String.t(), [module]) :: String.t()
  def format(contents, implementations) when is_binary(contents) and is_list(implementations) do
    Enum.reduce(implementations, contents, fn implementation, contents ->
      implementation.format(contents, [])
    end)
  end
end
