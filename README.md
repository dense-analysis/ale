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
by using the github repository URL for cloning the repository.

```vim
Plugin 'https://github.com/w0rp/ale.git'
```

See the Vundle documentation for more information.

### Installation manually

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
| D | [dmd](https://dlang.org/dmd-linux.html)^ |
| Fortran | [gcc](https://gcc.gnu.org/) |
| Haskell | [ghc](https://www.haskell.org/ghc/)^ |
| JavaScript | [eslint](http://eslint.org/), [jscs](http://jscs.info/), [jshint](http://jshint.com/) |
| Python | [flake8](http://flake8.pycqa.org/en/latest/) |
| Ruby   | [rubocop](https://github.com/bbatsov/rubocop) |

*^ Supported only on Unix machines via a wrapper script.*

If you would like to see support for more languages and tools, please
[create an issue](https://github.com/w0rp/ale/issues)
or [create a pull request](https://github.com/w0rp/ale/pulls).
If your tool can read from stdin or you have code to suggest which is good,
support can be happily added for more tools.
