# Used by "mix format"
[
  # Usage of new formatter plugin system in Elixir `>= 1.13.0`.
  plugins: [
    Eunomo.AliasSorter,
    Eunomo.ImportSorter,
    Eunomo.RequireSorter
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
