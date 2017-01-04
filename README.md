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

## Table of Contents

1. [Supported Languages and Tools](#supported-languages)
2. [Usage](#usage)
3. [Installation](#installation)
 1. [Installation with Pathogen](#installation-with-pathogen)
 2. [Installation with Vundle](#installation-with-vundle)
 3. [Manual Installation](#manual-installation)
4. [FAQ](#faq)
 1. [How do I disable particular linters?](#faq-disable-linters)
 2. [How can I keep the sign gutter open?](#faq-disable-linters)
 3. [How can I change the signs ALE uses?](#faq-change-signs)
 4. [How can I show errors or warnings in my statusline?](#faq-statusline)
 5. [How can I change the format for echo messages?](#faq-echo-format)
 6. [How can I execute some code when ALE stops linting?](#faq-autocmd)
 7. [How can I navigate between errors quickly?](#faq-navigation)
 8. [How can I run linters only when I save files?](#faq-lint-on-save)

<a name="supported-languages"></a>

## 1. Supported Languages and Tools

This plugin supports the following languages and tools. All available
tools will be run in combination, so they can be complementary.

<!--
Keep the table rows sorted alphabetically by the language name,
and the tools in the tools column sorted alphabetically by the tool
name. That seems to be the fairest way to arrange this table.
-->

| Language | Tools |
| -------- | ----- |
| Ansible | [ansible-lint](https://github.com/willthames/ansible-lint) |
| Bash | [-n flag](https://www.gnu.org/software/bash/manual/bash.html#index-set), [shellcheck](https://www.shellcheck.net/) |
| Bourne Shell | [-n flag](http://linux.die.net/man/1/sh), [shellcheck](https://www.shellcheck.net/) |
| C | [cppcheck](http://cppcheck.sourceforge.net), [gcc](https://gcc.gnu.org/), [clang](http://clang.llvm.org/)|
| C++ (filetype cpp) | [cppcheck] (http://cppcheck.sourceforge.net), [gcc](https://gcc.gnu.org/)|
| Chef | [foodcritic](http://www.foodcritic.io/) |
| CoffeeScript | [coffee](http://coffeescript.org/), [coffeelint](https://www.npmjs.com/package/coffeelint) |
| CSS | [csslint](http://csslint.net/), [stylelint](https://github.com/stylelint/stylelint) |
| Cython (pyrex filetype) | [cython](http://cython.org/) |
| D | [dmd](https://dlang.org/dmd-linux.html)^ |
| Elixir | [credo](https://github.com/rrrene/credo) |
| Elm | [elm-make](https://github.com/elm-lang/elm-make) |
| Fortran | [gcc](https://gcc.gnu.org/) |
| Go | [gofmt -e](https://golang.org/cmd/gofmt/), [go vet](https://golang.org/cmd/vet/), [golint](https://godoc.org/github.com/golang/lint), [go build](https://golang.org/cmd/go/) |
| Haskell | [ghc](https://www.haskell.org/ghc/), [hlint](https://hackage.haskell.org/package/hlint) |
| HTML | [HTMLHint](http://htmlhint.com/), [tidy](http://www.html-tidy.org/) |
| JavaScript | [eslint](http://eslint.org/), [jscs](http://jscs.info/), [jshint](http://jshint.com/), [flow](https://flowtype.org/) |
| JSON | [jsonlint](http://zaa.ch/jsonlint/) |
| LaTeX | [chktex](http://www.nongnu.org/chktex/), [lacheck](https://www.ctan.org/pkg/lacheck) |
| Lua | [luacheck](https://github.com/mpeterv/luacheck) |
| Markdown | [mdl](https://github.com/mivok/markdownlint), [proselint](http://proselint.com/)|
| MATLAB | [mlint](https://www.mathworks.com/help/matlab/ref/mlint.html) |
| OCaml | [merlin](https://github.com/the-lambda-church/merlin) see `:help ale-integration-ocaml-merlin` for configuration instructions
| Perl | [perl -c](https://perl.org/), [perl-critic](https://metacpan.org/pod/Perl::Critic) |
| PHP | [hack](http://hacklang.org/), [php -l](https://secure.php.net/), [phpcs](https://github.com/squizlabs/PHP_CodeSniffer) |
| Pug | [pug-lint](https://github.com/pugjs/pug-lint) |
| Puppet | [puppet](https://puppet.com), [puppet-lint](https://puppet-lint.com) |
| Python | [flake8](http://flake8.pycqa.org/en/latest/), [pylint](https://www.pylint.org/) |
| Ruby | [rubocop](https://github.com/bbatsov/rubocop) |
| SASS | [sass-lint](https://www.npmjs.com/package/sass-lint), [stylelint](https://github.com/stylelint/stylelint) |
| SCSS | [sass-lint](https://www.npmjs.com/package/sass-lint), [scss-lint](https://github.com/brigade/scss-lint), [stylelint](https://github.com/stylelint/stylelint) |
| Scala | [scalac](http://scala-lang.org) |
| Swift | [swiftlint](https://swift.org/) |
| Tex | [proselint](http://proselint.com/) |
| Text^^ | [proselint](http://proselint.com/) |
| TypeScript | [tslint](https://github.com/palantir/tslint), typecheck |
| Verilog | [iverilog](https://github.com/steveicarus/iverilog), [verilator](http://www.veripool.org/projects/verilator/wiki/Intro) |
| Vim | [vint](https://github.com/Kuniwak/vint) |
| YAML | [yamllint](https://yamllint.readthedocs.io/) |

* *^ Supported only on Unix machines via a wrapper script.*
* *^^ No text linters are enabled by default.*

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for more tools.

<a name="usage"></a>

## 2. Usage

Once this plugin is installed, while editing your files in supported
languages and tools which have been correctly installed,
this plugin will send the contents of your text buffers to a variety of
programs for checking the syntax and semantics of your programs. By default,
linters will be re-run in the background to check your syntax when you open
new buffers or as you make edits to your files.

The behaviour of linting can be configured with a variety of options,
documented in [the Vim help file](doc/ale.txt). For more information on the
options ALE offers, consult `:help ale-options` for global options and `:help
ale-linter-options` for options specified to particular linters.

<a name="installation"></a>

## 3. Installation

To install this plugin, you should use one of the following methods.
For Windows users, replace usage of the Unix `~/.vim` directory with
`%USERPROFILE%\_vim`, or another directory if you have configured
Vim differently. On Windows, your `~/.vimrc` file will be similarly
stored in `%USERPROFILE%\_vimrc`.

<a name="installation-with-pathogen"></a>

### 3.i. Installation with Pathogen

To install this module with [Pathogen](https://github.com/tpope/vim-pathogen),
you should clone this repository to your bundle directory, and ensure
you have the line `execute pathogen#infect()` in your `~/.vimrc` file.
You can run the following commands in your terminal to do so:

```bash
cd ~/.vim/bundle
git clone https://github.com/w0rp/ale.git
```

<a name="installation-with-vundle"></a>

### 3.ii. Installation with Vundle

You can install this plugin using [Vundle](https://github.com/VundleVim/Vundle.vim)
by using the path on GitHub for this repository.

```vim
Plugin 'w0rp/ale'
```

See the Vundle documentation for more information.

<a name="manual-installation"></a>

### 3.iii. Manual Installation

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

You can add the following line to generate documentation tags automatically,
if you don't have something similar already, so you can use the `:help` command
to consult ALE's online documentation:

```vim
silent! helptags ALL
```

Because the author of this plugin is a weird nerd, this is his preferred
installation method.

<a name="faq"></a>

## 4. FAQ

<a name="faq-disable-linters"></a>

### 4.i. How do I disable particular linters?

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

<a name="faq-keep-signs"></a>

### 4.ii. How can I keep the sign gutter open?

You can keep the sign gutter open at all times by setting the
`g:ale_sign_column_always` to 1

```vim
let g:ale_sign_column_always = 1
```

<a name="faq-change-signs"></a>

### 4.iii. How can I change the signs ALE uses?

Use these options to specify what text should be used for signs:

```vim
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
```

<a name="faq-statusline"></a>

### 4.iv. How can I show errors or warnings in my statusline?

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

<a name="faq-echo-format"></a>

### 4.v. How can I change the format for echo messages?

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

<a name="faq-autocmd"></a>

### 4.vi. How can I execute some code when ALE stops linting?

ALE runs its own [autocmd](http://vimdoc.sourceforge.net/htmldoc/autocmd.html)
event whenever has a linter has been successfully executed and processed. This
autocmd event can be used to call arbitrary functions after ALE stops linting.

```vim
augroup YourGroup
    autocmd!
    autocmd User ALELint call YourFunction()
augroup END
```

<a name="faq-navigation"></a>

### 4.vii. How can I navigate between errors quickly?

ALE offers some commands with `<Plug>` keybinds for moving between warnings and
errors quickly. You can map the keys Ctrl+j and Ctrl+k to moving between errors
for example:

```vim
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
```

For more information, consult the online documentation with
`:help ale-navigation-commands`.

<a name="faq-lint-on-save"></a>

### 4.viii. How can I run linters only when I save files?

ALE offers an option `g:ale_lint_on_save` for enabling running the linters
when files are saved. If you wish to run linters when files are saved, not
as you are editing files, then you can turn the option for linting
when text is changed off too.

```vim
" Write this in your vimrc file
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0
" You can disable this option too
" if you don't want linters to run on opening a file
let g:ale_lint_on_enter = 0
```
