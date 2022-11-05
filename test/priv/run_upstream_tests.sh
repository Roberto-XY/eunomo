#!/bin/bash
echo $(elixir --short-version)
if [[ "$(elixir --short-version)" == "1.14.1" ]]
then
    elixir -pr "lib/**/*.ex" -pr "test/upstream/**/*.exs"
fi
