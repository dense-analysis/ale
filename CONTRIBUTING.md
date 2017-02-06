# Contributing to ALE

1. [Guidelines](#guidelines)
2. [Creating Issues](#issues)
3. [Creating Pull Requests](#pull-requests)
 1. [Adding a New Linter](#adding-a-new-linter)
 2. [Adding New Options](#adding-new-options)

<a name="guidelines"></a>

# 1. Guidelines

Have fun, and work on whatever floats your boat. Take It Easy :tm:.

When writing code, follow the [Google Vimscript Style
Guide](https://google.github.io/styleguide/vimscriptguide.xml), and run `vint
-s` on your files to check for most of what the guide mentions and more. If you
install this plugin (ALE) and install [Vint](https://github.com/Kuniwak/vint), it
will check your code while you type.

<a name="issues"></a>

# 2. Creating Issues

Before creating any issues, please look through the current list of issues and
pull requests, and ensure that the issue hasn't already been reported. If an
issue has already been reported, but you have some new insight, please add
a comment to the existing issue.

Please read the FAQ in the README before creating any issues. A feature
you desire may already exist and be documented, or the FAQ might explain
how to solve a problem you have already.

Please try and describe any issues reported with as much detail as you can
provide about your Vim version, the linter you were trying to run, your
operating system, or any other information you think might be helpful.

Please describe your issue in clear, grammatically correct, and easy to
understand English. You are more likely to see an issue resolved if others
can understand you.

<a name="pull-requests"></a>

# 3. Creating Pull Requests

For code you write, make sure to credit yourself at the top of files you add,
and probably those you modify. You can write some comments at the top of your
VIM files.

```vim
" Author: John Smith <john.smith@gmail.com>
" Description: This file adds support for awesomelinter for the best language ever.
```

If you want to credit multiple authors, you can comma separate them.

```vim
" Author: John Smith <john.smith@gmail.com>, Jane Doe <https://jane-doe.info>
```

<a name="adding-a-new-linter"></a>

# 3.i. Adding a New Linter

If you add a new linter, look for existing handlers first in the
[handlers.vim](autoload/ale/handlers.vim) file. One of the handlers there may
already be able to handle your lines of output. If you find that your new
linter replicates an existing error handler, consider pulling it up into the
[handlers.vim](autoload/ale/handlers.vim) file, and use the generic handler in
both places.

When you add a linter, make sure the language for the linter and the linter
itself are present in the table in the [README.md](README.md) file and in the
Vim [help file](doc/ale.txt). The programs and linters should be sorted
alphabetically in the table and list.

<a name="adding-new-options"></a>

# 3.ii. Adding New Options

If you add new options to the plugin, make sure to document those new options
in the [README.md](README.md) file, and also in the [help file](doc/ale.txt).
Follow the format of other options in each. Global options should appear in the
README file, and in the relevant section in the help file. Options specific
to a particular linter should appear in the section for that linter.

Linter options for customizing general argument lists should be named
`g:ale_<filetype>_<linter>_options`, so that all linters can have similar
global variable names.

Any options for linters should be set to some default value so it is always
easy to see what the default is with `:echo g:ale...`.
