# Eunomo

The default Elixir formatter has the philosophy of not modifying non metadata parts of the AST.
`Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the default
formatter. As of now, the single use case is to sort `import`, `alias` and `require` definitions
alphabetically.

If you use Elixir version `< 1.13.0` you should use the provided `mix eunomo.gen.config`
& `mix eunomo` tasks. For `>= 1.13.0` the formatter comes with a [plugin
system](https://hexdocs.pm/mix/1.13.0/Mix.Tasks.Format.html#module-plugins). See the
`.formatter.exs` file in this repo for an example usage.

See [https://hexdocs.pm/eunomo](https://hexdocs.pm/eunomo) for further documentation.

https://github.com/Roberto-XY/eunomo


## Installation

The package can be installed by adding `eunomo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eunomo, only: :dev, "~> 1.0.0"}
  ]
end
```

## Usage

### Elixir `>= 1.13.0` & version `1.0.0`

```elixir
# .formatter.exs
[
  # Usage of new formatter plugin system in Elixir `>= 1.13.0`.
  plugins: [
    Eunomo.AliasSorter,
    Eunomo.ImportSorter,
    Eunomo.RequireSorter
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
```


### Elixir `< 1.13.0` & version `0.1.3 `

Before Elixir version `1.13.0`, there was no way to hook plugins into the default formatter. Hence
two Mix tasks were provided: [`mix eunomo.gen.config`](https://hexdocs.pm/eunomo/0.1.3/Mix.Tasks.Eunomo.Gen.Config.html) & [`mix eunomo`](https://hexdocs.pm/eunomo/0.1.3/Mix.Tasks.Eunomo.html#content).