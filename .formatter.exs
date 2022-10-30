# Used by "mix format"
[
  # Usage of new formatter plugin system in Elixir `>= 1.13.0`.
  plugins: [Eunomo],
  # all `sort_` options default to false if not present
  eunomo_opts: [
    sort_alias: true,
    sort_import: true,
    sort_require: true
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
