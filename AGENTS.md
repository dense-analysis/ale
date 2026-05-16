# ALE Instructions

## Basic Instructions

Read documentation from @doc/ale-development.txt to understand how to be an
ALE developer and how to match our standards.

Run all tests quickly with `./run-tests -q --fast`, which picks the quickest
version of Neovim we can run, and runs our linting checks.

You can quickly check an individual Vader test file by passing them as arguments
such as `./run-tests -q --fast test/path/some_file.vader`.

You can quickly run all Lua tests with `./run-tests -q --lua-only`.


For new Vim files, set `Author:` comments to the person doing the work.
Do not use Codex, OpenAI, or other tool names as the author.

## Writing Tests

For `test/test-files` they should almost always be 0 bytes in size and files
may be marked executable when testing searching for executables.
