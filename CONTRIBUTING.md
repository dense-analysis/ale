# Contributing to ALE

1. [Guidelines](#guidelines)
2. [Creating Issues](#issues)
3. [Creating Pull Requests](#pull-requests)
    1. [Adding a New Linter](#adding-a-new-linter)
    2. [Adding New Options](#adding-new-options)
4. [Writing Documentation](#writing-documentation)
    1. [Documenting New Linters](#documenting-new-linters)
    2. [Editing the Online Documentation](#editing-online-documentation)
    3. [Documenting Linter Options](#documenting-linter-options)
5. [In Case of Busses](#in-case-of-busses)

<a name="guidelines"></a>

## 1. Guidelines

Have fun, and work on whatever floats your boat. Take It Easy :tm:.

Don't forget to **write documentation** for whatever it is you are doing.
See the ["Writing Documentation"](#writing-documentation) section.

Remember to write Vader tests for most of the code you write. You can look at
existing Vader tests in the `test` directory for examples.

When writing code, follow the [Google Vimscript Style
Guide](https://google.github.io/styleguide/vimscriptguide.xml), and run `vint
-s` on your files to check for most of what the guide mentions and more. If you
install this plugin (ALE) and install [Vint](https://github.com/Kuniwak/vint), it
will check your code while you type.

<a name="issues"></a>

## 2. Creating Issues

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

## 3. Creating Pull Requests

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

### 3.i. Adding a New Linter

If you add a new linter, look for existing handlers first in the
[handlers](autoload/ale/handlers) directory. One of the handlers there may
already be able to handle your lines of output. If you find that your new
linter replicates an existing error handler, consider pulling it up into the
[handlers](autoload/ale/handlers) directory, and use the generic handler in
both places.

When you add a linter, make sure the language for the linter and the linter
itself are present in the table in the [README.md](README.md) file and in the
Vim [help file](doc/ale.txt). The programs and linters should be sorted
alphabetically in the table and list.

<a name="adding-new-options"></a>

### 3.ii. Adding New Options

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

<a name="writing-documentation"></a>

## 4. Writing Documentation

If you are adding new linters, changing the API, adding new options, etc., you
_must_ write some documentation describing it in the `doc/ale.txt` file.  New
linters _must_ be added to the `README.md` file too, so other users can get a
quick overview of the supported tools.

<a name="documenting-new-linters"></a>

### 4.i Documenting New Linters

If you add a new linter to the project, edit the table in the `README.md` file,
and edit the list of linters at the top of the `doc/ale.txt` file. The linters
should be sorted vertically in lexicographic (alphabetical) order by the
programming language name or filetype, and the tools for each language should
be sorted in lexicographic order horizontally. Sorting in this manner is a fair
manner of presenting all of the information in an easy to scan way, without
giving some unfair preference to any particular tool or language.

<a name="editing-online-documentation"></a>

### 4.ii Editing the Online Documentation

The "online documentation" file used for this project lives in `doc/ale.txt`.
This is the file used for generating `:help` text inside Vim itself. There are
some guidlines to follow for this file.

1. Keep all text within a column size of 79 characters, inclusive.
2. Open a section with 79 `=` or `-` characters, for headings and subheadings.
3. Sections should have a _single_ blank line before or after.
4. Between descriptions of variables/functions/commands, use _two_ blank lines.
5. Up-indent the description of a variable/function/command by two spaces.
6. Place tags at the ends of lines, with the final characters on column 79.
   All of the tags should line up perfectly on the same column as you scan
   down through the document.
7. Keep the table of contents balanced so the longest tag link ends on column
   79, and so all links line up perfectly on their first character, on the
   left.

<a name="documenting-linter-options"></a>

### 4.iii Documenting Linter Options

For documenting new linter options, please add a new sub-section under the
"Linter Specific Options" section describing all of the global options added
for each linter, and what the default values of the options are. All global
options for linters should be set to some default value. This will allow users
to look up the default value easily by typing `:echo g:ale_...`.

<a name="in-case-of-busses"></a>

## 5. In Case of Busses

Should the principal author of the ALE project and all collaborators with the
required access needed to properly administrate the project on GitHub or any
other website either perish or disappear, whether by tragic traffic accident
or government adduction, etc., action should be taken to ensure that the
project continues. If no one is left to administer the project where it is
hosted, please fork the project and nominate someone capable to administer it.
Preferably, in such an event, a single fork of the project will replace the
original, and life will go on, except the life of whoever vanished, because
then they will probably be dead.

Should w0rp suddenly disappear, then he was probably killed in a traffic
accident, or the government finally decided to kill him and make it look like
suicide. In the latter event, please subvert said government and restore
order to the universe, and ensure peace for mankind.
