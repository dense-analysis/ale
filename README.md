# Asynchronous Lint Engine [![Build Status](https://travis-ci.org/w0rp/ale.svg?branch=master)](https://travis-ci.org/w0rp/ale)

![ALE Logo by Mark Grealish - https://www.bhalash.com/](img/logo.jpg?raw=true)

ALE (Asynchronous Lint Engine) is a plugin for providing linting in NeoVim
and Vim 8 while you edit your text files.

![linting example](img/example.gif?raw=true)

ALE makes use of NeoVim and Vim 8 job control functions and timers to
run linters on the contents of text buffers and return errors as
text is changed in Vim. This allows for displaying warnings and
errors in files being edited in Vim before files have been saved
back to a filesystem.

In other words, this plugin allows you to lint while you type.

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
| Bash | [-n flag](https://www.gnu.org/software/bash/manual/bash.html#index-set), [shellcheck](https://www.shellcheck.net/) |
| Bourne Shell | [-n flag](http://linux.die.net/man/1/sh), [shellcheck](https://www.shellcheck.net/) |
| C | [gcc](https://gcc.gnu.org/) |
| C++ (filetype cpp)| [gcc](https://gcc.gnu.org/) |
| CoffeeScript | [coffee](http://coffeescript.org/), [coffeelint](https://www.npmjs.com/package/coffeelint) |
| CSS | [csslint](http://csslint.net/) |
| Cython (pyrex filetype) | [cython](http://cython.org/) |
| D | [dmd](https://dlang.org/dmd-linux.html)^ |
| Elixir | [credo](https://github.com/rrrene/credo) |
| Fortran | [gcc](https://gcc.gnu.org/) |
| Go | [gofmt -e](https://golang.org/cmd/gofmt/), [go vet](https://golang.org/cmd/vet/), [golint](https://godoc.org/github.com/golang/lint) |
| Haskell | [ghc](https://www.haskell.org/ghc/), [hlint](https://hackage.haskell.org/package/hlint) |
| HTML | [HTMLHint](http://htmlhint.com/), [tidy](http://www.html-tidy.org/) |
| JavaScript | [eslint](http://eslint.org/), [jscs](http://jscs.info/), [jshint](http://jshint.com/) |
| JSON | [jsonlint](http://zaa.ch/jsonlint/) |
| Lua | [luacheck](https://github.com/mpeterv/luacheck) |
| Perl | [perl -c](https://perl.org/), [perl-critic](https://metacpan.org/pod/Perl::Critic) |
| PHP | [php -l](https://secure.php.net/), [phpcs](https://github.com/squizlabs/PHP_CodeSniffer) |
| Pug | [pug-lint](https://github.com/pugjs/pug-lint) |
| Python | [flake8](http://flake8.pycqa.org/en/latest/) |
| Ruby | [rubocop](https://github.com/bbatsov/rubocop) |
| SASS | [sass-lint](https://www.npmjs.com/package/sass-lint) |
| SCSS | [sass-lint](https://www.npmjs.com/package/sass-lint), [scss-lint](https://github.com/brigade/scss-lint) |
| Scala | [scalac](http://scala-lang.org) |
| TypeScript | [tslint](https://github.com/palantir/tslint) |
| Verilog | [iverilog](https://github.com/steveicarus/iverilog), [verilator](http://www.veripool.org/projects/verilator/wiki/Intro) |
| Vim | [vint](https://github.com/Kuniwak/vint) |
| YAML | [yamllint](https://yamllint.readthedocs.io/) |

*^ Supported only on Unix machines via a wrapper script.*

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for more tools.

## Usage

Once this plugin is installed, while editing your files in supported
languages and tools which have been correctly installed,
this plugin will send the contents of your text buffers to a variety of
programs for checking the syntax and semantics of your programs. By default,
linters will be re-run in the background to check your syntax when you open
new buffers or as you make edits to your files.

### Options

A full list of options supported for configuring this plugin in your
vimrc file for all given linters is as follows:

| Option | Description | Default |
| ------ | ----------- | ------- |
| `g:ale_echo_cursor` | echo errors when the cursor is over them | `1` |
| `g:ale_echo_msg_format` | string format to use for the echoed message | `'%s'` |
| `g:ale_echo_msg_error_str` | string used for error severity in echoed message | `'Error'` |
| `g:ale_echo_msg_warning_str` | string used for warning severity in echoed message | `'Warning'` |
| `g:ale_lint_delay` | milliseconds to wait before linting | `200` |
| `g:ale_linters` | a dictionary of linters to whitelist | _not set_ |
| `g:ale_lint_on_enter` | lint when opening a file  | `1` |
| `g:ale_lint_on_save` | lint when saving a file  | `0` |
| `g:ale_lint_on_text_changed` | lint while typing  | `1` |
| `g:ale_set_loclist` | set the loclist with errors | `1` |
| `g:ale_set_signs` | set gutter signs with error markers | `has('signs')` |
| `g:ale_sign_column_always` | always show the sign gutter | `0` |
| `g:ale_sign_error` | the text to use for errors in the gutter | `'>>'` |
| `g:ale_sign_offset` | an offset for sign ids | `1000000` |
| `g:ale_sign_warning` | the text to use for warnings in the gutter | `'--'` |
| `g:ale_statusline_format` | string format to use in statusline flag | `['%d error(s)', '%d warning(s)', 'OK']` |
| `g:ale_warn_about_trailing_whitespace` | enable trailing whitespace warnings for some linters | `1` |

### Selecting Particular Linters

By default, all available tools for all supported languages will be run.
If you want to only select a subset of the tools, simply create a
`g:ale_linters` dictionary in your vimrc file mapping filetypes
to lists of linters to run.

```vim
let g:ale_linters = {
\   'javascript': ['eslint'],
\}
```

For all languages unspecified in the dictionary, all possible linters will
be run for those languages, just as when the dictionary is not defined.
Running many linters should not typically obstruct editing in Vim,
as they will all be executed in separate processes simultaneously.

This plugin will look for linters in the [`ale_linters`](ale_linters) directory.
Each directory within corresponds to a particular filetype in Vim, and each file
in each directory corresponds to the name of a particular linter.

### Always showing gutter

You can keep the sign gutter open at all times by setting the `g:ale_sign_column_always` to 1

```vim
let g:ale_sign_column_always = 1
```

### Customize signs

Use these options to specify what text should be used for signs:

```vim
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
```

### Statusline

You can use `ALEGetStatusLine()` to integrate ALE into vim statusline.
To enable it, you should have in your `statusline` settings

```vim
%{ALEGetStatusLine()}
```

When errors are detected a string showing the number of errors will be shown.
You can customize the output format using the global list `g:ale_statusline_format` where:

- The 1st element is for errors
- The 2nd element is for warnings
- The 3rd element is for when no errors are detected

e.g

```vim
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
```

![Statusline with issues](img/issues.png)
![Statusline with no issues](img/no_issues.png)


### Customize echoed message

There are 3 global options that allow customizing the echoed message.

- `g:ale_echo_msg_format` where:
  * `%s` is the error message itself
  * `%linter%` is the linter name
  * `%severity` is the severity type
- `g:ale_echo_msg_error_str` is the string used for error severity.
- `g:ale_echo_msg_warning_str` is the string used for warning severity.

So for example this:

```vim
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
```

Will give you:

![Echoed message](img/echo.png)

## Installation

To install this plugin, you should use one of the following methods.
For Windows users, replace usage of the Unix `~/.vim` directory with
`%USERPROFILE%\_vim`, or another directory if you have configured
Vim differently. On Windows, your `~/.vimrc` file will be similarly
stored in `%USERPROFILE%\_vimrc`.

### Installation with Pathogen

To install this module with [Pathogen](https://github.com/tpope/vim-pathogen),
you should clone this repository to your bundle directory, and ensure
you have the line `execute pathogen#infect()` in your `~/.vimrc` file.
You can run the following commands in your terminal to do so:

```bash
cd ~/.vim/bundle
git clone https://github.com/w0rp/ale.git
```

### Installation with Vundle

You can install this plugin using [Vundle](https://github.com/VundleVim/Vundle.vim)
by using the path on GitHub for this repository.

```vim
Plugin 'w0rp/ale'
```

See the Vundle documentation for more information.

### Manual Installation

For installation without a package manager, you can clone this git repository
into a bundle directory as with pathogen, and add the repository to your
runtime path yourself. First clone the repository.

```bash
cd ~/.vim/bundle
git clone https://github.com/w0rp/ale.git
```

Then, modify your `~/.vimrc` file to add this plugin to your runtime path.

```vim
set nocompatible
filetype off

let &runtimepath.=',~/.vim/bundle/ale'

filetype plugin on
```

Because the author of this plugin is a weird nerd, this is his preferred
installation method.
