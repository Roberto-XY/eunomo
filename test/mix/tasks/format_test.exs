# credo:disable-for-this-file
Code.require_file("../../upstream_test_helper.exs", __DIR__)

defmodule Mix.Tasks.FormatTest do
  use MixTest.Case

  @content """
  defmodule Foo do
  alias Eunomo.Z.{L, I}
  alias     Eunomo.Z

  require              Eunomo.Z
  require Eunomo.C
                   import Eunomo.Z, only: [hello_world:              0      ]
  import Eunomo.C
  end
  """

  test "formats alias blocks, import blocks, require blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true, sort_import: true, sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z
               alias Eunomo.Z.{L, I}

               require Eunomo.C
               require Eunomo.Z
               import Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
             end
             """
    end)
  end

  test "formats alias blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z
               alias Eunomo.Z.{L, I}

               require Eunomo.Z
               require Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
               import Eunomo.C
             end
             """
    end)
  end

  test "formats import blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_import: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z.{L, I}
               alias Eunomo.Z

               require Eunomo.Z
               require Eunomo.C
               import Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
             end
             """
    end)
  end

  test "formats require blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z.{L, I}
               alias Eunomo.Z

               require Eunomo.C
               require Eunomo.Z
               import Eunomo.Z, only: [hello_world: 0]
               import Eunomo.C
             end
             """
    end)
  end

  test "formats alias blocks, import blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true, sort_import: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z
               alias Eunomo.Z.{L, I}

               require Eunomo.Z
               require Eunomo.C
               import Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
             end
             """
    end)
  end

  test "formats alias blocks, require blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true, sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z
               alias Eunomo.Z.{L, I}

               require Eunomo.C
               require Eunomo.Z
               import Eunomo.Z, only: [hello_world: 0]
               import Eunomo.C
             end
             """
    end)
  end

  test "formats import blocks, require blocks, and also the file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_import: true, sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z.{L, I}
               alias Eunomo.Z

               require Eunomo.C
               require Eunomo.Z
               import Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
             end
             """
    end)
  end

  test "formats without any resorts in file", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", "foo bar")

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true, sort_import: true, sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == "foo(bar)\n"
    end)
  end

  test "formats without any sorts enabled", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", @content)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      Mix.Tasks.Format.run(["a.ex"])

      assert Mix.Tasks.Format.run(["a.ex", "--check-formatted"]) == :ok

      assert File.read!("a.ex") == """
             defmodule Foo do
               alias Eunomo.Z.{L, I}
               alias Eunomo.Z

               require Eunomo.Z
               require Eunomo.C
               import Eunomo.Z, only: [hello_world: 0]
               import Eunomo.C
             end
             """
    end)
  end

  test "--check-formatted fails if not sorted", context do
    in_tmp(context.test, fn ->
      File.write!("a.ex", """
      defmodule Foo do
        alias Eunomo.B
        alias Eunomo.A
      end
      """)

      File.write!(".formatter.exs", """
      [
        plugins: [Eunomo],
        eunomo_opts: [sort_alias: true, sort_import: true, sort_require: true],
        inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
      ]
      """)

      assert Mix.Tasks.Format.run(["a.ex", "--dry-run"]) == :ok

      assert_raise Mix.Error, ~r"mix format failed due to --check-formatted", fn ->
        Mix.Tasks.Format.run(["a.ex", "--check-formatted"])
      end
    end)
  end
end
