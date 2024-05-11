ExUnit.start()

IO.puts("Elixir version: #{System.version()}")

if System.version() != "1.16.2" do
  ExUnit.configure(exclude: [upstream: true])
else
  IO.puts("Running with upstream tests.")
end
