#!/bin/bash
echo $(elixir --short-version)
if [[ "$(elixir --short-version)" == "1.14.1" ]]
then
    elixir -pr "lib/**/*.ex" -r "test/mix/tasks/upstream_format_test.exs" -r "test/upstream_test_helper.exs"
fi
