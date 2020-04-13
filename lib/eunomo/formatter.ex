defmodule Eunomo.Formatter do
  @moduledoc false

  alias Eunomo.LineMap

  @doc """
  Formats an `Eunomo.LineMap`.

  Invariants that should hold:

    - input and output are valid `Eunomo.LineMap`s.
    - input and out are compilable Elixir files that produce the same runtime behaviour.
  """
  @callback format(LineMap.t()) :: LineMap.t()

  @doc """
  Applies all given implementation modules sequentially to the `Eunomo.LineMap`.

  Returns the final `Eunomo.LineMap` with all modifications applied.
  """
  @spec format(LineMap.t(), [module]) :: LineMap.t()
  def format(line_map, implementations) when is_map(line_map) and is_list(implementations) do
    Enum.reduce(implementations, line_map, fn implementation, line_map ->
      implementation.format(line_map)
    end)
  end

  @doc """
  Applies the given implementation module to the `Eunomo.LineMap`.

  Returns the modified `Eunomo.LineMap`.
  """
  @spec format(LineMap.t(), module) :: LineMap.t()
  def format(line_map, implementation) when is_map(line_map) and is_atom(implementation) do
    implementation.format(line_map)
  end
end
