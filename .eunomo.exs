# Used by "mix eunomo" with Elixir `< 1.13.0`
[
  inputs: :read_from_dot_formatter,
  formatter: [
    Eunomo.AliasSorter,
    Eunomo.ImportSorter,
    Eunomo.RequireSorter
  ]
]
