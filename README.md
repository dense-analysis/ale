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

| Language | Tools |
| -------- | ----- |
| Bash | -n flag |
| Bourne Shell | -n flag |
| JavaScript | [eslint](http://eslint.org/) |
| Python | [flake8](http://flake8.pycqa.org/en/latest/) |

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for more tools.
