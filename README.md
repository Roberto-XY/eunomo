# Eunomo

The default Elixir formatter has the philosophy of not modifying non metadata parts of the AST.
`Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the default
formatter. As of now the single use case is to sort `import`, `alias` and `require` definitions
alphabetically.

By default the `mix eunomo.gen.config` & `mix eunomo` tasks are provided.

See [https://hexdocs.pm/eunomo](https://hexdocs.pm/eunomo) for further documentation.

## Installation

The package can be installed by adding `eunomo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eunomo, only: :dev, "~> 0.1.1"}
  ]
end
```
