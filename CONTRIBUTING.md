# Contributing to ALE

1. [Guidelines](#guidelines)
2. [Creating Pull Requests](#pull-requests)

<a name="guidelines"></a>

# 1. Guidelines

Have fun, and work on whatever floats your boat. Take It Easy :tm:.

<a name="pull-requests"></a>

# 2. Creating Pull Requests

For code you write, make sure to credit yourself at the top of files you add, and probably those you modify. You can write
some comments at the top of your VIM files.

```vim
" Author: John Smith <john.smith@gmail.com>
" Description: This file adds support for awesomelinter to the best language ever.
```

If you want to credit multiple authors, you can comma separate them.

```vim
" Author: John Smith <john.smith@gmail.com>, Jane Doe <https://jane-doe.info>
```

# 2.1. Adding a new linter

If you add a new linter, look for existing handlers first in the [handlers.vim](plugin/ale/handlers.vim) file. One of the handlers
there may already be able to handle your lines of output. If you find that your new linter replicates an existing error handler,
consider pulling it up into the [handlers.vim](plugin/ale/handlers.vim) file, and use the generic handler in both places.

When you add a linter, make sure the language for the linter and the linter itself are present in the table in the
[README.md](README.md) file and in the Vim [help file](doc/ale.txt). The programs and linters are sorted alphabetically in the
table and list.
