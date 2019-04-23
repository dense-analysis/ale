# Asynchronous Lint Engine [![Travis CI Build Status](https://travis-ci.org/w0rp/ale.svg?branch=master)](https://travis-ci.org/w0rp/ale) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/r0ef1xu8xjmik58d/branch/master?svg=true)](https://ci.appveyor.com/project/w0rp/ale) [![Join the chat at https://gitter.im/vim-ale/Lobby](https://badges.gitter.im/vim-ale/Lobby.svg)](https://gitter.im/vim-ale/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


![ALE Logo by Mark Grealish - https://www.bhalash.com/](img/logo.jpg?raw=true)

ALE (Asynchronous Lint Engine) is a plugin providing linting (syntax checking
and semantic errors) in NeoVim 0.2.0+ and Vim 8 while you edit your text files,
and acts as a Vim [Language Server Protocol](https://langserver.org/) client.

<img src="img/example.gif?raw=true" alt="A linting example with the darkspectrum color scheme in GVim." title="A linting example with the darkspectrum color scheme in GVim.">

ALE makes use of NeoVim and Vim 8 job control functions and timers to
run linters on the contents of text buffers and return errors as
text is changed in Vim. This allows for displaying warnings and
errors in files being edited in Vim before files have been saved
back to a filesystem.

In other words, this plugin allows you to lint while you type.

ALE offers support for fixing code with command line tools in a non-blocking
manner with the `:ALEFix` feature, supporting tools in many languages, like
`prettier`, `eslint`, `autopep8`, and more.

ALE acts as a "language client" to support a variety of Language Server Protocol
features, including:

* Diagnostics (via Language Server Protocol linters)
* Go To Definition (`:ALEGoToDefinition`)
* Completion (Built in completion support, or with Deoplete)
* Finding references (`:ALEFindReferences`)
* Hover information (`:ALEHover`)
* Symbol search (`:ALESymbolSearch`)

If you don't care about Language Server Protocol, ALE won't load any of the code
for working with it unless needed. One of ALE's general missions is that you
won't pay for the features that you don't use.

If you enjoy this plugin, feel free to contribute or check out the author's
other content at [w0rp.com](https://w0rp.com).

## Table of Contents

1. [Supported Languages and Tools](#supported-languages)
2. [Usage](#usage)
    1. [Linting](#usage-linting)
    2. [Fixing](#usage-fixing)
    3. [Completion](#usage-completion)
    4. [Go To Definition](#usage-go-to-definition)
    5. [Find References](#usage-find-references)
    6. [Hovering](#usage-hover)
    7. [Symbol Search](#usage-symbol-search)
3. [Installation](#installation)
    1. [Installation with Vim package management](#standard-installation)
    2. [Installation with Pathogen](#installation-with-pathogen)
    3. [Installation with Vundle](#installation-with-vundle)
    4. [Installation with Vim-Plug](#installation-with-vim-plug)
4. [Contributing](#contributing)
5. [FAQ](#faq)
    1. [How do I disable particular linters?](#faq-disable-linters)
    2. [How can I keep the sign gutter open?](#faq-keep-signs)
    3. [How can I change the signs ALE uses?](#faq-change-signs)
    4. [How can I change or disable the highlights ALE uses?](#faq-change-highlights)
    5. [How can I show errors or warnings in my statusline?](#faq-statusline)
    6. [How can I show errors or warnings in my lightline?](#faq-lightline)
    7. [How can I change the format for echo messages?](#faq-echo-format)
    8. [How can I execute some code when ALE starts or stops linting?](#faq-autocmd)
    9. [How can I navigate between errors quickly?](#faq-navigation)
    10. [How can I run linters only when I save files?](#faq-lint-on-save)
    11. [How can I use the quickfix list instead of the loclist?](#faq-quickfix)
    12. [How can I check JSX files with both stylelint and eslint?](#faq-jsx-stylelint-eslint)
    13. [How can I check Vue files with ESLint?](#faq-vue-eslint)
    14. [Will this plugin eat all of my laptop battery power?](#faq-my-battery-is-sad)
    15. [How can I configure my C or C++ project?](#faq-c-configuration)
    16. [How can I configure ALE differently for different buffers?](#faq-buffer-configuration)
    17. [How can I configure the height of the list in which ALE displays errors?](#faq-list-window-height)
    18. [How can I see what ALE has configured for the current file?](#faq-get-info)

<a name="supported-languages"></a>

## 1. Supported Languages and Tools

ALE supports a wide variety of languages and tools. See the
[full list](supported-tools.md) in the
[Supported Languages and Tools](supported-tools.md) page.

<a name="usage"></a>

## 2. Usage

<a name="usage-linting"></a>

### 2.i Linting

Once this plugin is installed, while editing your files in supported
languages and tools which have been correctly installed,
this plugin will send the contents of your text buffers to a variety of
programs for checking the syntax and semantics of your programs. By default,
linters will be re-run in the background to check your syntax when you open
new buffers or as you make edits to your files.

The behaviour of linting can be configured with a variety of options,
documented in [the Vim help file](doc/ale.txt). For more information on the
options ALE offers, consult `:help ale-options` for global options and `:help
ale-integration-options` for options specified to particular linters.

<a name="usage-fixing"></a>

### 2.ii Fixing

ALE can fix files with the `ALEFix` command. Functions need to be configured
either in each buffer with a `b:ale_fixers`, or globally with `g:ale_fixers`.

The recommended way to configure fixers is to define a List in an ftplugin file.

```vim
" In ~/.vim/ftplugin/javascript.vim, or somewhere similar.

" Fix files with prettier, and then ESLint.
let b:ale_fixers = ['prettier', 'eslint']
" Equivalent to the above.
let b:ale_fixers = {'javascript': ['prettier', 'eslint']}
```

You can also configure your fixers from vimrc using `g:ale_fixers`, before or
after ALE has been loaded.

A `*` in place of the filetype will apply a List of fixers to all files which
do not match some filetype in the Dictionary.

Note that using a plain List for `g:ale_fixers` is not supported.

```vim
" In ~/.vim/vimrc, or somewhere similar.
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\}
```

If you want to automatically fix files when you save them, you need to turn
a setting on in vimrc.

```vim
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
```

The `:ALEFixSuggest` command will suggest some supported tools for fixing code.
Both `g:ale_fixers` and `b:ale_fixers` can also accept functions, including
lambda functions, as fixers, for fixing files with custom tools.

See `:help ale-fix` for complete information on how to fix files with ALE.

<a name="usage-completion"></a>

### 2.iii Completion

ALE offers some support for completion via hijacking of omnicompletion while you
type. All of ALE's completion information must come from Language Server
Protocol linters, or from `tsserver` for TypeScript.

ALE integrates with [Deoplete](https://github.com/Shougo/deoplete.nvim) as a
completion source, named `'ale'`. You can configure Deoplete to only use ALE as
the source of completion information, or mix it with other sources.

```vim
" Use ALE and also some plugin 'foobar' as completion sources for all code.
let g:deoplete#sources = {'_': ['ale', 'foobar']}
```

ALE also offers its own automatic completion support, which does not require any
other plugins, and can be enabled by changing a setting before ALE is loaded.

```vim
" Enable completion where available.
" This setting must be set before ALE is loaded.
let g:ale_completion_enabled = 1
```

See `:help ale-completion` for more information.

<a name="usage-go-to-definition"></a>

### 2.iv Go To Definition

ALE supports jumping to the definition of words under your cursor with the
`:ALEGoToDefinition` command using any enabled Language Server Protocol linters
and `tsserver`.

See `:help ale-go-to-definition` for more information.

<a name="usage-find-references"></a>

### 2.v Find References

ALE supports finding references for words under your cursor with the
`:ALEFindReferences` command using any enabled Language Server Protocol linters
and `tsserver`.

See `:help ale-find-references` for more information.

<a name="usage-hover"></a>

### 2.vi Hovering

ALE supports "hover" information for printing brief information about symbols at
the cursor taken from Language Server Protocol linters and `tsserver` with the
`ALEHover` command.

The information can be displayed in a `balloon` tooltip in Vim or GVim by
hovering your mouse over symbols. Mouse hovering is enabled by default in GVim,
and needs to be configured for Vim 8.1+ in terminals.

See `:help ale-hover` for more information.

<a name="usage-symbol-search"></a>

### 2.vii Symbol Search

ALE supports searching for workspace symbols via Language Server Protocol
linters with the `ALESymbolSearch` command.

Search queries can be performed to find functions, types, and more which are
similar to a given query string.

See `:help ale-symbol-search` for more information.

<a name="installation"></a>

## 3. Installation

To install this plugin, you should use one of the following methods.
For Windows users, replace usage of the Unix `~/.vim` directory with
`%USERPROFILE%\vimfiles`, or another directory if you have configured
Vim differently. On Windows, your `~/.vimrc` file will be similarly
stored in `%USERPROFILE%\_vimrc`.

<a name="standard-installation"></a>

### 3.i. Installation with Vim package management

In Vim 8 and NeoVim, you can install plugins easily without needing to use
any other tools. Simply clone the plugin into your `pack` directory.

#### Vim 8 on Unix

```bash
mkdir -p ~/.vim/pack/git-plugins/start
git clone https://github.com/w0rp/ale.git ~/.vim/pack/git-plugins/start/ale
```

#### NeoVim on Unix

```bash
mkdir -p ~/.local/share/nvim/site/pack/git-plugins/start
git clone https://github.com/w0rp/ale.git ~/.local/share/nvim/site/pack/git-plugins/start/ale
```

#### Vim 8 on Windows

```bash
# Run these commands in the "Git for Windows" Bash terminal
mkdir -p ~/vimfiles/pack/git-plugins/start
git clone https://github.com/w0rp/ale.git ~/vimfiles/pack/git-plugins/start/ale
```

#### Generating Vim help files

You can add the following line to your vimrc files to generate documentation
tags automatically, if you don't have something similar already, so you can use
the `:help` command to consult ALE's online documentation:

```vim
" Put these lines at the very end of your vimrc file.

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
```

<a name="installation-with-pathogen"></a>

### 3.ii. Installation with Pathogen

To install this module with [Pathogen](https://github.com/tpope/vim-pathogen),
you should clone this repository to your bundle directory, and ensure
you have the line `execute pathogen#infect()` in your `~/.vimrc` file.
You can run the following commands in your terminal to do so:

```bash
cd ~/.vim/bundle
git clone https://github.com/w0rp/ale.git
```

<a name="installation-with-vundle"></a>

### 3.iii. Installation with Vundle

You can install this plugin using [Vundle](https://github.com/VundleVim/Vundle.vim)
by using the path on GitHub for this repository.

```vim
Plugin 'w0rp/ale'
```

See the Vundle documentation for more information.

<a name="installation-with-vim-plug"></a>

### 3.iiii. Installation with Vim-Plug

You can install this plugin using [Vim-Plug](https://github.com/junegunn/vim-plug)
by adding the GitHub path for this repository to your `~/.vimrc`
and running `:PlugInstall`.

```vim
Plug 'w0rp/ale'
```

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

By default, all available tools for all supported languages will be run. If you
want to only select a subset of the tools, you can define `b:ale_linters` for a
single buffer, or `g:ale_linters` globally.

The recommended way to configure linters is to define a List in an ftplugin
file.

```vim
" In ~/.vim/ftplugin/javascript.vim, or somewhere similar.

" Enable ESLint only for JavaScript.
let b:ale_linters = ['eslint']

" Equivalent to the above.
let b:ale_linters = {'javascript': ['eslint']}
```

You can also declare which linters you want to run in your vimrc file, before or
after ALE has been loaded.

```vim
" In ~/.vim/vimrc, or somewhere similar.
let g:ale_linters = {
\   'javascript': ['eslint'],
\}
```

For all languages unspecified in the dictionary, all possible linters will
be run for those languages, just as when the dictionary is not defined.
Running many linters should not typically obstruct editing in Vim,
as they will all be executed in separate processes simultaneously.

If you don't want ALE to run anything other than what you've explicitly asked
for, you can set `g:ale_linters_explicit` to `1`.

```vim
" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1
```

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

<a name="faq-change-highlights"></a>

### 5.iv. How can I change or disable the highlights ALE uses?

ALE's highlights problems with highlight groups which link to `SpellBad`,
`SpellCap`, `error`, and `todo` groups by default. The characters that are
highlighted depend on the linters being used, and the information provided to
ALE.

Highlighting can be disabled completely by setting `g:ale_set_highlights` to
`0`.

```vim
" Set this in your vimrc file to disabling highlighting
let g:ale_set_highlights = 0
```

You can control all of the highlights ALE uses, say if you are using a different
color scheme which produces ugly highlights. For example:

```vim
highlight ALEWarning ctermbg=DarkMagenta
```

See `:help ale-highlights` for more information.

<a name="faq-statusline"></a>

### 5.v. How can I show errors or warnings in my statusline?

[vim-airline](https://github.com/vim-airline/vim-airline) integrates with ALE
for displaying error information in the status bar. If you want to see the
status for ALE in a nice format, it is recommended to use vim-airline with ALE.
The airline extension can be enabled by adding the following to your vimrc:

```vim
" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
```

If you don't want to use vim-airline, you can implement your own statusline
function without adding any other plugins. ALE provides some functions to
assist in this endeavour, including:

* `ale#statusline#Count`: Which returns the number of problems found by ALE
  for a specified buffer.
* `ale#statusline#FirstProblem`: Which returns a dictionary containing the
  full loclist details of the first problem of a specified type found by ALE
  in a buffer. (e.g. The first style warning in the current buffer.)
  This can be useful for displaying more detailed information such as the
  line number of the first problem in a file.

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

See `:help ale#statusline#Count()` or `:help ale#statusline#FirstProblem()`
for more information.

<a name="faq-lightline"></a>

### 5.vi. How can I show errors or warnings in my lightline?

[lightline](https://github.com/itchyny/lightline.vim) does not have built-in
support for ALE, nevertheless there is a plugin that adds this functionality: [maximbaz/lightline-ale](https://github.com/maximbaz/lightline-ale).

For more information, check out the sources of that plugin, `:help ale#statusline#Count()` and [lightline documentation](https://github.com/itchyny/lightline.vim#advanced-configuration).

<a name="faq-echo-format"></a>

### 5.vii. How can I change the format for echo messages?

There are 3 global options that allow customizing the echoed message.

- `g:ale_echo_msg_format` where:
    * `%s` is the error message itself
    * `%...code...%` is an optional error code, and most characters can be
      written between the `%` characters.
    * `%linter%` is the linter name
    * `%severity%` is the severity type
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

See `:help g:ale_echo_msg_format` for more information.

<a name="faq-autocmd"></a>

### 5.viii. How can I execute some code when ALE starts or stops linting?

ALE runs its own [autocmd](http://vimdoc.sourceforge.net/htmldoc/autocmd.html)
events when a lint or fix cycle are started and stopped. There is also an event
that runs when a linter job has been successfully started. These events can be
used to call arbitrary functions during these respective parts of the ALE's
operation.

```vim
augroup YourGroup
    autocmd!
    autocmd User ALELintPre    call YourFunction()
    autocmd User ALELintPost   call YourFunction()

    autocmd User ALEJobStarted call YourFunction()

    autocmd User ALEFixPre     call YourFunction()
    autocmd User ALEFixPost    call YourFunction()
augroup END
```

<a name="faq-navigation"></a>

### 5.ix. How can I navigate between errors quickly?

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

### 5.x. How can I run linters only when I save files?

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

### 5.xi. How can I use the quickfix list instead of the loclist?

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

You can also set `let g:ale_list_vertical = 1` to open the windows vertically
instead of the default horizontally.

<a name="faq-jsx-stylelint-eslint"></a>

### 5.xii. How can I check JSX files with both stylelint and eslint?

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
options in a jsx.vim ftplugin file.

```vim
" In ~/.vim/ftplugin/jsx.vim, or somewhere similar.
let b:ale_linter_aliases = ['css', 'javascript']
let b:ale_linters = ['stylelint', 'eslint']
```

Or if you want, you can configure the linters from your vimrc file.

```vim
" In ~/.vim/vimrc, or somewhere similar.
let g:ale_linter_aliases = {'jsx': ['css', 'javascript']}
let g:ale_linters = {'jsx': ['stylelint', 'eslint']}
```

ALE will alias the `jsx` filetype so it uses the `css` filetype linters, and
use the original Array of selected linters for `jsx` from the `g:ale_linters`
object. All available linters will be used for the filetype `javascript`, and
no linter will be run twice for the same file.

<a name="faq-vue-eslint"></a>

### 5.xiii. How can I check Vue files with ESLint?

To check Vue files with ESLint, your ESLint project configuration file must be
configured to use the [Vue plugin](https://github.com/vuejs/eslint-plugin-vue).
After that, you need to configure ALE so it will run the JavaScript ESLint
linter on your files. The settings you need are similar to the settings needed
for checking JSX code with both stylelint and ESLint, in the previous section.

```vim
" In ~/.vim/ftplugin/vue.vim, or somewhere similar.

" Run both javascript and vue linters for vue files.
let b:ale_linter_aliases = ['javascript', 'vue']
" Select the eslint and vls linters.
let b:ale_linters = ['eslint', 'vls']
```

Run `:ALEInfo` to see which linters are available after telling ALE to run
JavaScript linters on Vue files. Not all linters support checking Vue files.

If you don't want to configure your linters in ftplugin files for some reason,
you can configure them from your vimrc file instead.

```vim
" In ~/.vim/vimrc, or somewhere similar.
let g:ale_linter_aliases = {'vue': ['vue', 'javascript']}
let g:ale_linters = {'vue': ['eslint', 'vls']}
```

<a name="faq-my-battery-is-sad"></a>

### 5.xiv. Will this plugin eat all of my laptop battery power?

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

<a name="faq-c-configuration"></a>

### 5.xv. How can I configure my C or C++ project?

The structure of C and C++ projects varies wildly from project to project, with
many different build tools being used for building them, and many different
formats for project configuration files. ALE can run compilers easily, but
ALE cannot easily detect which compiler flags to use.

Some tools and build configurations can generate
[compile_commands.json](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
files. The `cppcheck`, `clangcheck`, `clangtidy` and `cquery` linters can read
these files for automatically determining the appropriate compiler flags to
use.

For linting with compilers like `gcc` and `clang`, and with other tools, you
will need to tell ALE which compiler flags to use yourself. You can use
different options for different projects with the `g:ale_pattern_options`
setting.  Consult the documentation for that setting for more information.
`b:ale_linters` can be used to select which tools you want to run, say if you
want to use only `gcc` for one project, and only `clang` for another.

You may also configure buffer-local settings for linters with project-specific
vimrc files. [local_vimrc](https://github.com/LucHermitte/local_vimrc) can be
used for executing local vimrc files which can be shared in your project.

<a name="faq-buffer-configuration"></a>

### 5.xvi. How can I configure ALE differently for different buffers?

ALE offers various ways to configure which linters or fixers are run, and
other settings. For the majority of ALE's settings, they can either be
configured globally with a `g:` variable prefix, or for a specific buffer
with a `b:` variable prefix. For example, you can configure a Python ftplugin
file like so.

```vim
" In ~/.vim/ftplugin/python.vim

" Check Python files with flake8 and pylint.
let b:ale_linters = ['flake8', 'pylint']
" Fix Python files with autopep8 and yapf.
let b:ale_fixers = ['autopep8', 'yapf']
" Disable warnings about trailing whitespace for Python files.
let b:ale_warn_about_trailing_whitespace = 0
```

For configuring files based on regular expression patterns matched against the
absolute path to a file, you can use `g:ale_pattern_options`.

```vim
" Do not lint or fix minified files.
let g:ale_pattern_options = {
\ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\}
" If you configure g:ale_pattern_options outside of vimrc, you need this.
let g:ale_pattern_options_enabled = 1
```

Buffer-local variables for settings always override the global settings.

<a name="faq-list-window-height"></a>

### 5.xvii. How can I configure the height of the list in which ALE displays errors?

To set a default height for the error list, use the `g:ale_list_window_size` variable.

```vim
" Show 5 lines of errors (default: 10)
let g:ale_list_window_size = 5
```

<a name="faq-get-info"></a>

### 5.xviii. How can I see what ALE has configured for the current file?

Run the following to see what is currently configured:

```vim
:ALEInfo
```
