# Eunomo

The default Elixir formatter has the philosophy of not modifying non metadata parts of the AST.
`Eunomo` does not adhere to this philosophy and is meant to be used as an extension to the default
formatter. As of now, the single use case is to sort `import`, `alias` and `require` definitions
alphabetically.

See [https://hexdocs.pm/eunomo](https://hexdocs.pm/eunomo) for further documentation &
https://github.com/Roberto-XY/eunomo for the source code.


## Installation

The package can be installed by adding `eunomo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eunomo, "~> 2.0.0", only: :dev}
  ]
end
```

## Usage

### Elixir `>= 1.13.0` & version `2.0.0`

Uses Elixir formatter [plugin
system](https://hexdocs.pm/mix/1.13.0/Mix.Tasks.Format.html#module-plugins).

```elixir
# .formatter.exs
[
  # Usage of new formatter plugin system in Elixir `>= 1.13.0`.
  plugins: [Eunomo],
  eunomo_opts: [
    sort_alias: true,
    sort_import: true,
    sort_require: true
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
```

Running `mix format` is going to take over as usal from here. All `mix format` options also apply to
Eunomo plugins.

### Elixir `< 1.13.0` & version `0.1.3 `

Before Elixir version `1.13.0`, there was no way to hook plugins into the default formatter. Hence
two Mix tasks were provided: [`mix
eunomo.gen.config`](https://hexdocs.pm/eunomo/0.1.3/Mix.Tasks.Eunomo.Gen.Config.html) & [`mix
eunomo`](https://hexdocs.pm/eunomo/0.1.3/Mix.Tasks.Eunomo.html#content). This approach does not play
nicely with umbrella applications.
