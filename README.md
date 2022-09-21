# Eunomo

The default Elixir formatter has the philosophy of not modifying non metadata parts of the AST.
`Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the default
formatter. As of now the single use case is to sort `import`, `alias` and `require` definitions
alphabetically.

If you use Elixir version `< 1.13.0` you should use the provided `mix eunomo.gen.config`
& `mix eunomo` tasks. For `>= 1.13.0` the formatter comes with a [plugin
system](https://hexdocs.pm/mix/1.13.0/Mix.Tasks.Format.html#module-plugins). See the
`.formatter.exs` file in this repo for an example usage.

See [https://hexdocs.pm/eunomo](https://hexdocs.pm/eunomo) for further documentation.

## Installation

The package can be installed by adding `eunomo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eunomo, only: :dev, "~> 1.0.0"}
  ]
end
```
