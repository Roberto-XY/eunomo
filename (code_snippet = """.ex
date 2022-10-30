(code_snippet = """
alias Eunomo.Z.{L, I}
alias Eunomo.Z
alias __MODULE__.B
alias __MODULE__.A
alias Eunomo.{
      L,
      B,
      # test
}
alias Eunomo.C
\nalias Eunomo.PG.Repo
alias A
alias Eunomo.Patient
""")
Eunomo.AliasSorter.format(code_snippet, []) |> IO.puts


The issue is that the plugin system does not handle multiple formatters for the same extension. I did not notice that because it is not documented & I only tested the individual formatters. Unfortunate :(

v 1.14:
https://github.com/elixir-lang/elixir/blob/eb43a6a444c4aa9446ec1a7ad9801cedc897ab9d/lib/mix/lib/mix/tasks/format.ex#L511

```elixir
  defp find_formatter_for_file(file, formatter_opts) do
    ext = Path.extname(file)

    cond do
      plugin = find_plugin_for_extension(formatter_opts, ext) ->
        &plugin.format(&1, [extension: ext, file: file] ++ formatter_opts)

      ext in ~w(.ex .exs) ->
        &elixir_format(&1, [file: file] ++ formatter_opts)

      true ->
        & &1
    end
  end
```

[In current main](https://github.com/elixir-lang/elixir/blob/b39f0e324edbf98808c72e6578ff2d3b751508fd/lib/mix/lib/mix/tasks/format.ex#L539) that already was partially fixed by allowing it for plugins. But still not in the combination with `.ex/s` files.

https://github.com/elixir-lang/elixir/pull/12032
## What to do?
For now, sticking to the old release is the best course of action.
- Ask upstream for the intention & possibly fix. Especially because of [this PR](https://github.com/elixir-lang/elixir/pull/11507), so the intention to make this possible seems to be there, let's see if we can get a fix in.
- Just pull the release :)
- Call elixir formatting in each plugin explicitly—the worst-case hack
