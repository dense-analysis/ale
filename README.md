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

ALE also supports fixing problems with files by running commands in the
background with a command `ALEFix`.

## Table of Contents

1. [Supported Languages and Tools](#supported-languages)
2. [Usage](#usage)
3. [Installation](#installation)
    1. [Installation with Pathogen](#installation-with-pathogen)
    2. [Installation with Vundle](#installation-with-vundle)
    3. [Manual Installation](#manual-installation)
4. [Contributing](#contributing)
5. [FAQ](#faq)
    1. [How do I disable particular linters?](#faq-disable-linters)
    2. [How can I keep the sign gutter open?](#faq-keep-signs)
    3. [How can I change the signs ALE uses?](#faq-change-signs)
    4. [How can I show errors or warnings in my statusline?](#faq-statusline)
    5. [How can I change the format for echo messages?](#faq-echo-format)
    6. [How can I execute some code when ALE stops linting?](#faq-autocmd)
    7. [How can I navigate between errors quickly?](#faq-navigation)
    8. [How can I run linters only when I save files?](#faq-lint-on-save)
    9. [How can I use the quickfix list instead of the loclist?](#faq-quickfix)
    10. [How can I check JSX files with both stylelint and eslint?](#faq-jsx-stylelint-eslint)
    11. [Will this plugin eat all of my laptop battery power?](#faq-my-battery-is-sad)

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
| ASM | [gcc](https://gcc.gnu.org) |
| Ansible | [ansible-lint](https://github.com/willthames/ansible-lint) |
| AsciiDoc | [proselint](http://proselint.com/)|
| Awk | [gawk](https://www.gnu.org/software/gawk/)|
| Bash | [-n flag](https://www.gnu.org/software/bash/manual/bash.html#index-set), [shellcheck](https://www.shellcheck.net/) |
| Bourne Shell | [-n flag](http://linux.die.net/man/1/sh), [shellcheck](https://www.shellcheck.net/) |
| C | [cppcheck](http://cppcheck.sourceforge.net), [gcc](https://gcc.gnu.org/), [clang](http://clang.llvm.org/)|
| C++ (filetype cpp) | [clang](http://clang.llvm.org/), [clangcheck](http://clang.llvm.org/docs/ClangCheck.html), [clangtidy](http://clang.llvm.org/extra/clang-tidy/), [cppcheck](http://cppcheck.sourceforge.net), [cpplint](https://github.com/google/styleguide/tree/gh-pages/cpplint), [gcc](https://gcc.gnu.org/)|
| C# | [mcs](http://www.mono-project.com/docs/about-mono/languages/csharp/) |
| Chef | [foodcritic](http://www.foodcritic.io/) |
| CMake | [cmakelint](https://github.com/richq/cmake-lint) |
| CoffeeScript | [coffee](http://coffeescript.org/), [coffeelint](https://www.npmjs.com/package/coffeelint) |
| Crystal | [crystal](https://crystal-lang.org/) |
| CSS | [csslint](http://csslint.net/), [stylelint](https://github.com/stylelint/stylelint) |
| Cython (pyrex filetype) | [cython](http://cython.org/) |
| D | [dmd](https://dlang.org/dmd-linux.html) |
| Dockerfile | [hadolint](https://github.com/lukasmartinelli/hadolint) |
| Elixir | [credo](https://github.com/rrrene/credo), [dogma](https://github.com/lpil/dogma) |
| Elm | [elm-make](https://github.com/elm-lang/elm-make) |
| Erb | [erb](https://github.com/jeremyevans/erubi) |
| Erlang | [erlc](http://erlang.org/doc/man/erlc.html) |
| Fortran | [gcc](https://gcc.gnu.org/) |
| FusionScript | [fusion-lint](https://github.com/RyanSquared/fusionscript) |
| Go | [gofmt -e](https://golang.org/cmd/gofmt/), [go vet](https://golang.org/cmd/vet/), [golint](https://godoc.org/github.com/golang/lint), [gometalinter](https://github.com/alecthomas/gometalinter), [go build](https://golang.org/cmd/go/), [gosimple](https://github.com/dominikh/go-tools/tree/master/cmd/gosimple), [staticcheck](https://github.com/dominikh/go-tools/tree/master/cmd/staticcheck) |
| Haml | [haml-lint](https://github.com/brigade/haml-lint)
| Handlebars | [ember-template-lint](https://github.com/rwjblue/ember-template-lint) |
| Haskell | [ghc](https://www.haskell.org/ghc/), [ghc-mod](https://github.com/DanielG/ghc-mod), [hlint](https://hackage.haskell.org/package/hlint), [hdevtools](https://hackage.haskell.org/package/hdevtools) |
| HTML | [HTMLHint](http://htmlhint.com/), [proselint](http://proselint.com/), [tidy](http://www.html-tidy.org/) |
| Java | [checkstyle](http://checkstyle.sourceforge.net), [javac](http://www.oracle.com/technetwork/java/javase/downloads/index.html) |
| JavaScript | [eslint](http://eslint.org/), [jscs](http://jscs.info/), [jshint](http://jshint.com/), [flow](https://flowtype.org/), [standard](http://standardjs.com/), [prettier](https://github.com/prettier/prettier) (and `prettier-eslint`, `prettier-standard`), [xo](https://github.com/sindresorhus/xo)
| JSON | [jsonlint](http://zaa.ch/jsonlint/) |
| Kotlin | [kotlinc](https://kotlinlang.org), [ktlint](https://ktlint.github.io) see `:help ale-integration-kotlin` for configuration instructions
| LaTeX | [chktex](http://www.nongnu.org/chktex/), [lacheck](https://www.ctan.org/pkg/lacheck), [proselint](http://proselint.com/) |
| Lua | [luacheck](https://github.com/mpeterv/luacheck) |
| Markdown | [mdl](https://github.com/mivok/markdownlint), [proselint](http://proselint.com/), [vale](https://github.com/ValeLint/vale) |
| MATLAB | [mlint](https://www.mathworks.com/help/matlab/ref/mlint.html) |
| Nim | [nim](https://nim-lang.org/docs/nimc.html) |
| nix | [nix-instantiate](http://nixos.org/nix/manual/#sec-nix-instantiate) |
| nroff | [proselint](http://proselint.com/)|
| Objective-C | [clang](http://clang.llvm.org/) |
| Objective-C++ | [clang](http://clang.llvm.org/) |
| OCaml | [merlin](https://github.com/the-lambda-church/merlin) see `:help ale-integration-ocaml-merlin` for configuration instructions
| Perl | [perl -c](https://perl.org/), [perl-critic](https://metacpan.org/pod/Perl::Critic) |
| PHP | [hack](http://hacklang.org/), [php -l](https://secure.php.net/), [phpcs](https://github.com/squizlabs/PHP_CodeSniffer), [phpmd](https://phpmd.org) |
| Pod | [proselint](http://proselint.com/)|
| Pug | [pug-lint](https://github.com/pugjs/pug-lint) |
| Puppet | [puppet](https://puppet.com), [puppet-lint](https://puppet-lint.com) |
| Python | [autopep8](https://github.com/hhatto/autopep8), [flake8](http://flake8.pycqa.org/en/latest/), [isort](https://github.com/timothycrosley/isort), [mypy](http://mypy-lang.org/), [pylint](https://www.pylint.org/), [yapf](https://github.com/google/yapf) |
| R | [lintr](https://github.com/jimhester/lintr) |
| ReasonML | [merlin](https://github.com/the-lambda-church/merlin) see `:help ale-integration-reason-merlin` for configuration instructions
| reStructuredText | [proselint](http://proselint.com/)|
| RPM spec | [rpmlint](https://github.com/rpm-software-management/rpmlint) (disabled by default; see `:help ale-integration-spec`) |
| Ruby | [brakeman](http://brakemanscanner.org/), [reek](https://github.com/troessner/reek), [rubocop](https://github.com/bbatsov/rubocop), [ruby](https://www.ruby-lang.org) |
| Rust | [rustc](https://www.rust-lang.org/), cargo (see `:help ale-integration-rust` for configuration instructions) |
| SASS | [sass-lint](https://www.npmjs.com/package/sass-lint), [stylelint](https://github.com/stylelint/stylelint) |
| SCSS | [sass-lint](https://www.npmjs.com/package/sass-lint), [scss-lint](https://github.com/brigade/scss-lint), [stylelint](https://github.com/stylelint/stylelint) |
| Scala | [scalac](http://scala-lang.org) |
| Slim | [slim-lint](https://github.com/sds/slim-lint)
| SML | [smlnj](http://www.smlnj.org/) |
| Stylus | [stylelint](https://github.com/stylelint/stylelint) |
| SQL | [sqlint](https://github.com/purcell/sqlint) |
| Swift | [swiftlint](https://swift.org/) |
| Texinfo | [proselint](http://proselint.com/)|
| Text^ | [proselint](http://proselint.com/), [vale](https://github.com/ValeLint/vale) |
| TypeScript | [eslint](http://eslint.org/), [tslint](https://github.com/palantir/tslint), tsserver, typecheck |
| Verilog | [iverilog](https://github.com/steveicarus/iverilog), [verilator](http://www.veripool.org/projects/verilator/wiki/Intro) |
| Vim | [vint](https://github.com/Kuniwak/vint) |
| Vim help^ | [proselint](http://proselint.com/)|
| XHTML | [proselint](http://proselint.com/)|
| XML | [xmllint](http://xmlsoft.org/xmllint.html/)|
| YAML | [yamllint](https://yamllint.readthedocs.io/) |

* *^ No linters for text or Vim help filetypes are enabled by default.*

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

ALE can fix files with the `ALEFix` command. Functions need to be configured
for different filetypes with the `g:ale_fixers` variable. See `:help ale-fix`.

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

<a name="contributing"></a>

## 4. Contributing

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for it.

If you are interested in the general direction of the project, check out the
[wiki home page](https://github.com/w0rp/ale/wiki). The wiki includes a
Roadmap for the future, and more.

If you'd liked to discuss the project more directly, check out the `#vim-ale` channel
on Freenode. Web chat is available [here](https://webchat.freenode.net/?channels=vim-ale).

<a name="faq"></a>

## 5. FAQ

<a name="faq-disable-linters"></a>

### 5.i. How do I disable particular linters?

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

### 5.ii. How can I keep the sign gutter open?

You can keep the sign gutter open at all times by setting the
`g:ale_sign_column_always` to 1

```vim
let g:ale_sign_column_always = 1
```

<a name="faq-change-signs"></a>

### 5.iii. How can I change the signs ALE uses?

Use these options to specify what text should be used for signs:

```vim
let g:ale_sign_error = '>>'
let g:ale_sign_warning = '--'
```

ALE sets some background colors automatically for warnings and errors
in the sign gutter, with the names `ALEErrorSign` and `ALEWarningSign`.
These colors can be customised, or even removed completely:

```vim
highlight clear ALEErrorSign
highlight clear ALEWarningSign
```

<a name="faq-statusline"></a>

### 5.iv. How can I show errors or warnings in my statusline?

[vim-airline](https://github.com/vim-airline/vim-airline) integrates with ALE
for displaying error information in the status bar. If you want to see the
status for ALE in a nice format, it is recommended to use vim-airline with ALE.
The airline extension can be enabled by adding the following to your vimrc:

```vim
" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
```

If you don't want to use vim-airline, you can implement your own statusline
function without adding any other plugins. ALE provides a function for counting
the number of problems for this purpose, named `ale#statusline#Count`.

Say you want to display all errors as one figure, and all non-errors as another
figure. You can do the following:

```vim
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

set statusline=%{LinterStatus()}
```

See `:help ale#statusline#Count()` for more information.

<a name="faq-echo-format"></a>

### 5.v. How can I change the format for echo messages?

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

### 5.vi. How can I execute some code when ALE stops linting?

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

### 5.vii. How can I navigate between errors quickly?

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

### 5.viii. How can I run linters only when I save files?

ALE offers an option `g:ale_lint_on_save` for enabling running the linters
when files are saved. This option is enabled by default. If you only
wish to run linters when files are saved, you can turn the other
options off.

```vim
" Write this in your vimrc file
let g:ale_lint_on_text_changed = 'never'
" You can disable this option too
" if you don't want linters to run on opening a file
let g:ale_lint_on_enter = 0
```

If for whatever reason you don't wish to run linters again when you save
files, you can set `g:ale_lint_on_save` to `0`.

<a name="faq-quickfix"></a>

### 5.ix. How can I use the quickfix list instead of the loclist?

The quickfix list can be enabled by turning the `g:ale_set_quickfix`
option on. If you wish to also disable the loclist, you can disable
the `g:ale_set_loclist` option.

```vim
" Write this in your vimrc file
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
```

If you wish to show Vim windows for the loclist or quickfix items
when a file contains warnings or errors, `g:ale_open_list` can be
set to `1`. `g:ale_keep_list_window_open` can be set to `1`
if you wish to keep the window open even after errors disappear.

```vim
let g:ale_open_list = 1
" Set this if you want to.
" This can be useful if you are combining ALE with
" some other plugin which sets quickfix errors, etc.
let g:ale_keep_list_window_open = 1
```

<a name="faq-jsx-stylelint-eslint"></a>

### 5.x. How can I check JSX files with both stylelint and eslint?

If you configure ALE options correctly in your vimrc file, and install
the right tools, you can check JSX files with stylelint and eslint.

First, install eslint and install stylelint with
[stylelint-processor-styled-components](https://github.com/styled-components/stylelint-processor-styled-components).

Supposing you have installed both tools correctly, configure your .jsx files so
`jsx` is included in the filetype. You can use an `autocmd` for this.

```vim
augroup FiletypeGroup
    autocmd!
    au BufNewFile,BufRead *.jsx set filetype=javascript.jsx
augroup END
```

Supposing the filetype has been set correctly, you can set the following
options in your vimrc file:

```vim
let g:ale_linters = {'jsx': ['stylelint', 'eslint']}
let g:ale_linter_aliases = {'jsx': 'css'}
```

ALE will alias the `jsx` filetype so it uses the `css` filetype linters, and
use the original Array of selected linters for `jsx` from the `g:ale_linters`
object. All available linters will be used for the filetype `javascript`, and
no linter will be run twice for the same file.

<a name="faq-my-battery-is-sad"></a>

### 5.xi. Will this plugin eat all of my laptop battery power?

ALE takes advantage of the power of various tools to check your code. This of
course means that CPU time will be used to continuously check your code. If you
are concerned about the CPU time ALE will spend, which will of course imply
some cost to battery life, you can adjust your settings to make your CPU do
less work.

First, consider increasing the delay before which ALE will run any linters
while you type. ALE uses a timeout which is cancelled and reset every time you
type, and this delay can be increased so linters are run less often. See
`:help g:ale_lint_delay` for more information.

If you don't wish to run linters while you type, you can disable that
behaviour. Set `g:ale_lint_on_text_changed` to `never` or `normal`. You won't
get as frequent error checking, but ALE shouldn't block your ability to edit a
document after you save a file, so the asynchronous nature of the plugin will
still be an advantage.

If you are still concerned, you can turn the automatic linting off altogether,
including the option `g:ale_lint_on_enter`, and you can run ALE manually with
`:ALELint`.
