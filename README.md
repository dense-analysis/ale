# Asynchronous Lint Engine

[![Vim](https://img.shields.io/badge/VIM-%2311AB00.svg?style=for-the-badge&logo=vim&logoColor=white)](https://www.vim.org/) [![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/) [![CI](https://img.shields.io/github/actions/workflow/status/dense-analysis/ale/main.yml?branch=master&label=CI&logo=github&style=for-the-badge)](https://github.com/dense-analysis/ale/actions?query=event%3Apush+workflow%3ACI+branch%3Amaster++) [![AppVeyor Build Status](https://img.shields.io/appveyor/build/dense-analysis/ale?label=Windows&style=for-the-badge)](https://ci.appveyor.com/project/dense-analysis/ale) [![Join the Dense Analysis Discord server](https://img.shields.io/badge/chat-Discord-5865F2?style=for-the-badge&logo=appveyor)](https://discord.gg/5zFD6pQxDk)

![ALE Logo by Mark Grealish - https://www.bhalash.com/](https://user-images.githubusercontent.com/3518142/59195920-2c339500-8b85-11e9-9c22-f6b7f69637b8.jpg)

ALE (Asynchronous Lint Engine) is a plugin providing linting (syntax checking
and semantic errors) in Neovim 0.7.0+ and Vim 8.0+ while you edit your text files,
and acts as a Vim [Language Server Protocol](https://langserver.org/) client.

<video autoplay="true" muted="true" loop="true" controls="false" src="https://user-images.githubusercontent.com/3518142/210141215-8f2ff760-6a87-4704-a11e-c109b8e9ec41.mp4" title="An example showing what ALE can do."></video>

ALE makes use of Neovim and Vim 8 job control functions and timers to
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

**Help Wanted:** If you would like to help maintain this plugin by managing the
many issues and pull requests that are submitted, please send the author an
email at [dev@w0rp.com](mailto:dev@w0rp.com?subject=Helping%20with%20ALE).

If you enjoy this plugin, feel free to contribute or check out the author's
other content at [w0rp.com](https://w0rp.com).

## Why ALE?

ALE has been around for many years, and there are many ways to run asynchronous
linting and fixing of code in Vim. ALE offers the following.

* No dependencies for ALE itself
* Lightweight plugin architecture (No JavaScript or Python required)
* Low memory footprint
* Runs virtually everywhere, including remote shells, and in `git commit`
* Out of the box support for running particular linters and language servers
* Near-zero configuration with custom code for better defaults
* Highly customizable and well-documented (`:help ale-options`)
* Breaking changes for the plugin are extremely rare
* Integrates with Neovim's LSP client (0.8+) and diagnostics (0.7+)
* Support for older Vim and Neovim versions
* Windows support
* Well-integrated with other plugins

## Supported Languages and Tools

ALE supports a wide variety of languages and tools. See the
[full list](supported-tools.md) in the
[Supported Languages and Tools](supported-tools.md) page.

## Usage

<a name="usage-linting"></a>

### Linting

Once this plugin is installed, while editing your files in supported
languages and tools which have been correctly installed,
this plugin will send the contents of your text buffers to a variety of
programs for checking the syntax and semantics of your programs. By default,
linters will be re-run in the background to check your syntax when you open
new buffers or as you make edits to your files.

The behavior of linting can be configured with a variety of options,
documented in [the Vim help file](doc/ale.txt). For more information on the
options ALE offers, consult `:help ale-options` for global options and `:help
ale-integration-options` for options specified to particular linters.

<a name="usage-fixing"></a>

### Fixing

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

### Completion

ALE offers some support for completion via hijacking of omnicompletion while you
type. All of ALE's completion information must come from Language Server
Protocol linters, or from `tsserver` for TypeScript.

When running ALE in Neovim 0.8+, ALE will integrate with Neovim's LSP client by
default, and any auto-completion plugin that uses the native LSP client will
work when ALE runs language servers.
[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) is recommended as a
completion plugin worth trying in Neovim.

ALE integrates with [Deoplete](https://github.com/Shougo/deoplete.nvim) as a
completion source, named `'ale'`. You can configure Deoplete to only use ALE as
the source of completion information, or mix it with other sources.

```vim
" Use ALE and also some plugin 'foobar' as completion sources for all code.
call deoplete#custom#option('sources', {
\ '_': ['ale', 'foobar'],
\})
```

ALE also offers its own automatic completion support, which does not require any
other plugins, and can be enabled by changing a setting before ALE is loaded.

```vim
" Enable completion where available.
" This setting must be set before ALE is loaded.
"
" You should not turn this setting on if you wish to use ALE as a completion
" source for other completion plugins, like Deoplete.
let g:ale_completion_enabled = 1
```

ALE provides an omni-completion function you can use for triggering
completion manually with `<C-x><C-o>`.

```vim
set omnifunc=ale#completion#OmniFunc
```

ALE supports automatic imports from external modules. This behavior is enabled
by default and can be disabled by setting:

```vim
let g:ale_completion_autoimport = 0
```

Note that disabling auto import can result in missing completion items from some
LSP servers (e.g. eclipselsp). See `:help ale-completion` for more information.

<a name="usage-go-to-definition"></a>

### Go To Definition

ALE supports jumping to the definition of words under your cursor with the
`:ALEGoToDefinition` command using any enabled Language Server Protocol linters
and `tsserver`. In Neovim 0.8+, you can also use Neovim's built in `gd` keybind
and more.

See `:help ale-go-to-definition` for more information.

<a name="usage-find-references"></a>

### Find References

ALE supports finding references for words under your cursor with the
`:ALEFindReferences` command using any enabled Language Server Protocol linters
and `tsserver`.

See `:help ale-find-references` for more information.

<a name="usage-hover"></a>

### Hovering

ALE supports "hover" information for printing brief information about symbols at
the cursor taken from Language Server Protocol linters and `tsserver` with the
`ALEHover` command.

Truncated information will be displayed when the cursor rests on a symbol by
default, as long as there are no problems on the same line.

The information can be displayed in a `balloon` tooltip in Vim or GVim by
hovering your mouse over symbols. Mouse hovering is enabled by default in GVim,
and needs to be configured for Vim 8.1+ in terminals.

See `:help ale-hover` for more information.

<a name="usage-symbol-search"></a>

### Symbol Search

ALE supports searching for workspace symbols via Language Server Protocol
linters with the `ALESymbolSearch` command.

Search queries can be performed to find functions, types, and more which are
similar to a given query string.

See `:help ale-symbol-search` for more information.

<a name="usage-refactoring"></a>

### Refactoring: Rename, Actions

ALE supports renaming symbols in code such as variables or class
names with the `ALERename` command.

`ALEFileRename` will rename file and fix import paths (tsserver
only).

`ALECodeAction` will execute actions on the cursor or applied to a visual
range selection, such as automatically fixing errors.

See `:help ale-refactor` for more information.

## Installation

Add ALE to your runtime path in the usual ways.

If you have trouble reading `:help ale`, try the following.

```vim
packloadall | silent! helptags ALL
```

#### Vim `packload`:

```bash
mkdir -p ~/.vim/pack/git-plugins/start
git clone --depth 1 https://github.com/dense-analysis/ale.git ~/.vim/pack/git-plugins/start/ale
```

#### Neovim `packload`:

```bash
mkdir -p ~/.local/share/nvim/site/pack/git-plugins/start
git clone --depth 1 https://github.com/dense-analysis/ale.git ~/.local/share/nvim/site/pack/git-plugins/start/ale
```

#### Windows `packload`:

```bash
# Run these commands in the "Git for Windows" Bash terminal
mkdir -p ~/vimfiles/pack/git-plugins/start
git clone --depth 1 https://github.com/dense-analysis/ale.git ~/vimfiles/pack/git-plugins/start/ale
```

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'dense-analysis/ale'
```

#### [Vundle](https://github.com/VundleVim/Vundle.vim)

```vim
Plugin 'dense-analysis/ale'
```

#### [Pathogen](https://github.com/tpope/vim-pathogen)
```vim
git clone https://github.com/dense-analysis/ale ~/.vim/bundle/ale
```

#### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'dense-analysis/ale',
    config = function()
        -- Configuration goes here.
        local g = vim.g

        g.ale_ruby_rubocop_auto_correct_all = 1

        g.ale_linters = {
            ruby = {'rubocop', 'ruby'},
            lua = {'lua_language_server'}
        }
    end
}
```

## Contributing

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/dense-analysis/ale/issues)
or [create a pull request](https://github.com/dense-analysis/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for it.

If you are interested in the general direction of the project, check out the
[wiki home page](https://github.com/dense-analysis/ale/wiki). The wiki includes
a Roadmap for the future, and more.

If you'd liked to discuss ALE and more check out the Dense Analysis Discord
server here: https://discord.gg/5zFD6pQxDk

## FAQ

<a name="faq-disable-linters"></a>

### How do I disable particular linters?

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

### How do I disable a particular warning or error?

Warnings and errors should be configured in project configuration files for the
relevant tools. ALE supports disabling only warnings relating to trailing
whitespace, which Vim users often fix automatically.

```vim
" Disable whitespace warnings
let g:ale_warn_about_trailing_whitespace = 0
```

Users generally should not ignore warnings or errors in projects by changing
settings in their own editor. Instead, configure tools appropriately so any
other user of the same project will see the same problems.

<a name="faq-get-info"></a>

### How can I see what ALE has configured for the current file?

Run the following to see what is currently configured:

```vim
:ALEInfo
```

### How can I disable virtual text appearing at ends of lines?

By default, ALE displays errors and warnings with virtual text. The problems ALE
shows appear with comment-like syntax after every problem found. You can set ALE
to only show problems where the cursor currently lies like so.

```vim
let g:ale_virtualtext_cursor = 'current'
```

If you want to disable virtual text completely, apply the following.

```vim
let g:ale_virtualtext_cursor = 'disabled'
```

<a name="faq-keep-signs"></a>
<a name="faq-change-signs"></a>

### How can I customise signs?

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

You can configure the sign gutter open at all times, if you wish.

```vim
let g:ale_sign_column_always = 1
```

<a name="faq-change-highlights"></a>

### How can I change or disable the highlights ALE uses?

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

<a name="faq-echo-format"></a>

### How can I change the format for echo messages?

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

![Echoed message](https://user-images.githubusercontent.com/3518142/59195927-348bd000-8b85-11e9-88b6-508a094f1548.png)

See `:help g:ale_echo_msg_format` for more information.

<a name="faq-statusline"></a>
<a name="faq-lightline"></a>

### How can I customise the statusline?

#### lightline

[lightline](https://github.com/itchyny/lightline.vim) does not have built-in
support for ALE, nevertheless there is a plugin that adds this functionality:
[maximbaz/lightline-ale](https://github.com/maximbaz/lightline-ale).

For more information, check out the sources of that plugin,
`:help ale#statusline#Count()` and
[lightline documentation](https://github.com/itchyny/lightline.vim#advanced-configuration).

#### vim-airline

[vim-airline](https://github.com/vim-airline/vim-airline) integrates with ALE
for displaying error information in the status bar. If you want to see the
status for ALE in a nice format, it is recommended to use vim-airline with ALE.
The airline extension can be enabled by adding the following to your vimrc:

```vim
" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
```

#### Custom statusline

You can implement your own statusline function without adding any other plugins.
ALE provides some functions to assist in this endeavour, including:

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

<a name="faq-window-borders"></a>

### How can I change the borders for floating preview windows?

Borders for floating preview windows are enabled by default. You can use the
`g:ale_floating_window_border` setting to configure them.

You could disable the border with an empty list.

```vim
let g:ale_floating_window_border = []
```

If the terminal supports Unicode, you might try setting the value like below, to
make it look nicer.

```vim
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰', '│', '─']
```

Since vim's default uses nice Unicode characters when possible, you can trick
ale into using that default with

```vim
let g:ale_floating_window_border = repeat([''], 8)
```

<a name="faq-my-battery-is-sad"></a>

### Will this plugin eat all of my laptop battery power?

ALE takes advantage of the power of various tools to check your code. This of
course means that CPU time will be used to continuously check your code. If you
are concerned about the CPU time ALE will spend, which will of course imply
some cost to battery life, you can adjust your settings to make your CPU do
less work.

First, consider increasing the delay before which ALE will run any linters
while you type. ALE uses a timeout which is cancelled and reset every time you
type, and this delay can be increased so linters are run less often. See
`:help g:ale_lint_delay` for more information.

If you don't wish to run linters while you type, you can disable that behavior.
Set `g:ale_lint_on_text_changed` to `never`. You won't get as frequent error
checking, but ALE shouldn't block your ability to edit a document after you save
a file, so the asynchronous nature of the plugin will still be an advantage.

If you are still concerned, you can turn the automatic linting off altogether,
including the option `g:ale_lint_on_enter`, and you can run ALE manually with
`:ALELint`.

<a name="faq-coc-nvim"></a>
<a name="faq-vim-lsp"></a>

### How can I use ALE with other LSP clients?

ALE offers an API for letting any other plugin integrate with ALE. If you are
interested in writing an integration, see `:help ale-lint-other-sources`.

If you're running ALE in Neovim with
[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for configuring
particular language servers, ALE will automatically disable its LSP
functionality for any language servers configured with nvim-lspconfig by
default. The following setting is applied by default:

```vim
let g:ale_disable_lsp = 'auto'
```

If you are running ALE in combination with another LSP client, you may wish to
disable ALE's LSP functionality entirely. You can change the setting to `1` to
always disable all LSP functionality.

```vim
let g:ale_disable_lsp = 1
```

You can also use `b:ale_disable_lsp` in your ftplugin files to enable or disable
LSP features in ALE for different filetypes.

#### Neovim Diagnostics

If you are running Neovim 0.7 or later, you can make ALE display errors and
warnings via the Neovim diagnostics API.

```vim
let g:ale_use_neovim_diagnostics_api = 1
```

<!-- We could expand this section to say a little more. -->

#### coc.nvim

[coc.nvim](https://github.com/neoclide/coc.nvim) is a popular Vim plugin written
in TypeScript and dependent on the [npm](https://www.npmjs.com/) ecosystem for
providing full IDE features to Vim. Both ALE and coc.nvim implement
[Language Server Protocol](https://microsoft.github.io/language-server-protocol/)
(LSP) clients for supporting diagnostics (linting with a live server), and other
features like auto-completion, and others listed above.

ALE is primarily focused on integrating with external programs through virtually
any means, provided the plugin remains almost entirely written in Vim script.
coc.nvim is primarily focused on bringing IDE features to Vim. If you want to
run external programs on your files to check for errors, and also use the most
advanced IDE features, you might want to use both plugins at the same time.

The easiest way to get both plugins to work together is to configure coc.nvim to
send diagnostics to ALE, so ALE controls how all problems are presented to you,
and to disable all LSP features in ALE, so ALE doesn't try to provide LSP
features already provided by coc.nvim, such as auto-completion.

Open your coc.nvim configuration file with `:CocConfig` and add
`"diagnostic.displayByAle": true` to your settings.

#### vim-lsp

[vim-lsp](https://github.com/prabirshrestha/vim-lsp) is a popular plugin as
implementation of Language Server Protocol (LSP) client for Vim. It provides
all the LSP features including auto completion, diagnostics, go to definitions,
etc.

[vim-lsp-ale](https://github.com/rhysd/vim-lsp-ale) is a bridge plugin to solve
the problem when using both ALE and vim-lsp. With the plugin, diagnostics are
provided by vim-lsp and ALE can handle all the errors. Please read
[vim-lsp-ale's documentation](https://github.com/rhysd/vim-lsp-ale/blob/master/doc/vim-lsp-ale.txt)
for more details.

<a name="faq-autocmd"></a>

### How can I execute some code when ALE starts or stops linting?

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

### How can I navigate between errors quickly?

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

### How can I run linters only when I save files?

ALE offers an option `g:ale_lint_on_save` for enabling running the linters when
files are saved. This option is enabled by default. If you only wish to run
linters when files are saved, you can turn the other options off.

```vim
" Write this in your vimrc file
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
" You can disable this option too
" if you don't want linters to run on opening a file
let g:ale_lint_on_enter = 0
```

If for whatever reason you don't wish to run linters again when you save files,
you can set `g:ale_lint_on_save` to `0`.

<a name="faq-quickfix"></a>

### How can I use the quickfix list instead of the loclist?

The quickfix list can be enabled by turning the `g:ale_set_quickfix` option on.
If you wish to also disable the loclist, you can disable the `g:ale_set_loclist`
option.

```vim
" Write this in your vimrc file
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
```

If you wish to show Vim windows for the loclist or quickfix items when a file
contains warnings or errors, `g:ale_open_list` can be set to `1`.
`g:ale_keep_list_window_open` can be set to `1` if you wish to keep the window
open even after errors disappear.

```vim
let g:ale_open_list = 1
" Set this if you want to.
" This can be useful if you are combining ALE with
" some other plugin which sets quickfix errors, etc.
let g:ale_keep_list_window_open = 1
```

You can also set `let g:ale_list_vertical = 1` to open the windows vertically
instead of the default horizontally.

### Why isn't ALE checking my filetype?

<a name="faq-jsx-stylelint-eslint"></a>

#### stylelint for JSX

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

#### Checking Vue with ESLint

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

<a name="faq-c-configuration"></a>

### How can I configure my C or C++ project?

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

ALE will attempt to parse `compile_commands.json` files to discover compiler
flags to use when linting code. See `:help g:ale_c_parse_compile_commands` for
more information. See Clang's documentation for
[compile_commands.json files](https://clang.llvm.org/docs/JSONCompilationDatabase.html).
You should strongly consider generating them in your builds, which is easy to do
with CMake.

You can also configure ALE to automatically run `make -n` to run dry runs on
`Makefile`s to discover compiler flags. This can execute arbitrary code, so the
option is disabled by default. See `:help g:ale_c_parse_makefile`.

<a name="faq-vm"></a>

### How can I run linters or fixers via Docker or a VM?

ALE supports running linters or fixers via Docker, virtual machines, or in
combination with any remote machine with a different file system, so long as the
tools are well-integrated with ALE, and ALE is properly configured to run the
correct commands and map filename paths between different file systems. See
`:help ale-lint-other-machines` for the full documentation on how to configure
ALE to support this.
