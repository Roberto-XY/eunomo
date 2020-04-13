defmodule B do
  @moduledoc """
  Documentation for `Eunomo`.
  """
  alias Eunomia.B
  alias Eunomo.A, as: Route

  def test do
    "hello"
  end

  alias Eunomo.C
  alias Eunomo.Z

  alias Eunomo.{
    L,
    B,
    # test
    Elixir.Z,
    Elixir.A
  }

  alias Eunomo.Z.{L, I}

  "alias Eunomo.C
  alias Eunomo.Z
  alias Eunomo.{B, Elixir.A, Elixir.Z, L}"

  """
  alias Eunomo.C
  alias Eunomo.Z\n\n
  alias Eunomo.{B, E\nlixir.A, Elixir.Z, L}
  """

  '\n'

  import Enum
  import List

  alias My.Long.Module.Name
  alias My.Other.Module.Example
end
