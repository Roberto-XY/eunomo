defmodule FileTest do
  use ExUnit.Case

  test "sorts alias blocks, import blocks, require blocks, and also formats the file" do
    content = """
        defmodule Foo do
        alias Eunomo.Z.{L, I}
        alias Eunomo.Z
      end
    """

    IO.inspect(content, label: :content)

    assert :ok == File.write("foo.ex", content)

    {formatter, opts} = Mix.Tasks.Format.formatter_for_file("foo.ex")

    IO.inspect(formatter, label: :formatter)
    IO.inspect(opts, label: :opts)

    {:ok, file} = File.read("foo.ex")

    formatted_string =
      formatter.(file) |> IO.iodata_to_binary() |> IO.inspect(label: :formatted_file)

    expected_result = """
    defmodule Foo do
      alias Eunomo.Z
      alias Eunomo.Z.{L, I}
    end
    """

    assert :ok = File.rm("foo.ex")

    IO.inspect(expected_result, label: :expected_result)
    formatted_properly? = String.equivalent?(formatted_string, expected_result)

    assert formatted_properly?
  end
end
