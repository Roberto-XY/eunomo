ExUnit.start()

defmodule TestHelpers do
  def clone_repo do
    repo = "https://github.com/phoenixframework/phoenix.git"
    repo = "https://github.com/elixir-ecto/ecto.git"
    version = "v1.4.16"
    version = "v3.4.0"
    basename = Path.basename(repo, ".git")

    System.cmd("git", ["clone", "--branch", version, "--single-branch", repo, "priv/#{basename}"],
      stderr_to_stdout: true,
      into: IO.stream(:stdio, :line)
    )
  end

  def test_repo do
    repo = "https://github.com/phoenixframework/phoenix.git"
    repo = "https://github.com/elixir-ecto/ecto.git"
    basename = Path.basename(repo, ".git")

    System.cmd("mix", ["deps.get"],
      stderr_to_stdout: true,
      cd: "priv/#{basename}",
      into: IO.stream(:stdio, :line)
    )

    {output, _} =
      System.cmd("mix", ["test"],
        stderr_to_stdout: true,
        cd: "priv/#{basename}"
      )
  end
end
