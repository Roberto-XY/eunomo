# Upstream copied from https://github.com/elixir-lang/elixir/blob/v1.14.1/lib/mix/test/test_helper.exs

Mix.start()
Mix.shell(Mix.Shell.Process)
Application.put_env(:mix, :colors, enabled: false)

Logger.remove_backend(:console)
Application.put_env(:logger, :backends, [])

ExUnit.start()

# # Clear environment variables that may affect tests
System.delete_env("http_proxy")
System.delete_env("https_proxy")
System.delete_env("HTTP_PROXY")
System.delete_env("HTTPS_PROXY")
System.delete_env("MIX_ENV")
System.delete_env("MIX_TARGET")

defmodule MixTest.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import MixTest.Case
    end
  end

  @apps Enum.map(Application.loaded_applications(), &elem(&1, 0))

  setup do
    on_exit(fn ->
      Application.start(:logger)
      Mix.env(:dev)
      Mix.target(:host)
      Mix.Task.clear()
      Mix.Shell.Process.flush()
      Mix.State.clear_cache()
      Mix.ProjectStack.clear_stack()
      delete_tmp_paths()

      for {app, _, _} <- Application.loaded_applications(), app not in @apps do
        Application.stop(app)
        Application.unload(app)
      end

      :ok
    end)

    :ok
  end

  def tmp_path do
    Path.expand("../tmp", __DIR__)
  end

  def tmp_path(extension) do
    Path.join(tmp_path(), remove_colons(extension))
  end

  defp remove_colons(term) do
    term
    |> to_string()
    |> String.replace(":", "")
  end

  def in_tmp(which, function) do
    path = tmp_path(which)
    File.rm_rf!(path)
    File.mkdir_p!(path)
    File.cd!(path, function)
  end

  defp delete_tmp_paths do
    tmp = tmp_path() |> String.to_charlist()
    for path <- :code.get_path(), :string.str(path, tmp) != 0, do: :code.del_path(path)
  end
end
