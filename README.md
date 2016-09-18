# ALE - Asynchronous Lint Engine

ALE (Asynchronous Lint Engine) is a plugin for providing linting in NeoVim
and Vim 8 while you edit your text files.

ALE makes use of NeoVim and Vim 8 job control functions and timers to
run linters on the contents of text buffers and return errors as
text is changed in Vim. This allows for displaying warnings and
errors in files being edited in Vim before files have been saved
back to a filesystem.

In other words, this plugin allows you to lint while you type.

**NOTE:** This Vim plugin has been written pretty quickly so far,
and is still in rapid development. Documentation and stable APIs will
follow later.

## Supported Languages and Tools

This plugin supports the following languages and tools. All available
tools will be run in combination, so they can be complementary.

<!--
Keep the table rows sorted alphabetically by the language name,
and the tools in the tools column sorted alphabetically by the tool
name. That seems to be the fairest way to arrange this table.
-->

| Language | Tools |
| -------- | ----- |
| Bash | [-n flag](https://www.gnu.org/software/bash/manual/bash.html#index-set) |
| Bourne Shell | [-n flag](http://linux.die.net/man/1/sh) |
| C | [gcc](https://gcc.gnu.org/) |
| D | [dmd](https://dlang.org/dmd-linux.html)\* |
| Fortran | [gcc](https://gcc.gnu.org/) |
| Haskell | [ghc](https://www.haskell.org/ghc/)\* |
| JavaScript | [eslint](http://eslint.org/), [jscs](http://jscs.info/), [jshint](http://jshint.com/) |
| Python | [flake8](http://flake8.pycqa.org/en/latest/) |
| Ruby   | [rubocop](https://github.com/bbatsov/rubocop) |

*\** *Supported only on Unix machines via a wrapper script.*

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for more tools.
