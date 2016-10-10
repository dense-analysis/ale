scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Description: This file defines some standard error format handlers. Any
"   linter which outputs warnings and errors in a format accepted by one of
"   these functions can simply use one of these pre-defined error handlers.

if exists('g:loaded_ale_handlers')
    finish
endif

let g:loaded_ale_handlers = 1

function! ale#handlers#HandleGCCFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " <stdin>:8:5: warning: conversion lacks type at end of format [-Wformat=]
    " <stdin>:10:27: error: invalid operands to binary - (have ‘int’ and ‘char *’)
    " -:189:7: note: $/${} is unnecessary on arithmetic variables. [SC2004]
    let pattern = '^.\+:\(\d\+\):\(\d\+\): \([^:]\+\): \(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

function! ale#handlers#HandleCSSLintFormat(buffer, lines) abort
    " Matches patterns line the following:
    "
    " something.css: line 2, col 1, Error - Expected RBRACE at line 2, col 1. (errors)
    " something.css: line 2, col 5, Warning - Expected (inline | block | list-item | inline-block | table | inline-table | table-row-group | table-header-group | table-footer-group | table-row | table-column-group | table-column | table-cell | table-caption | grid | inline-grid | run-in | ruby | ruby-base | ruby-text | ruby-base-container | ruby-text-container | contents | none | -moz-box | -moz-inline-block | -moz-inline-box | -moz-inline-grid | -moz-inline-stack | -moz-inline-table | -moz-grid | -moz-grid-group | -moz-grid-line | -moz-groupbox | -moz-deck | -moz-popup | -moz-stack | -moz-marker | -webkit-box | -webkit-inline-box | -ms-flexbox | -ms-inline-flexbox | flex | -webkit-flex | inline-flex | -webkit-inline-flex) but found 'wat'. (known-properties)
    "
    " These errors can be very massive, so the type will be moved to the front
    " so you can actually read the error type.
    let pattern = '^.*: line \(\d\+\), col \(\d\+\), \(Error\|Warning\) - \(.\+\) (\([^)]\+\))$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[4]
        let type = l:match[3]
        let errorGroup = l:match[5]

        " Put the error group at the front, so we can see what kind of error
        " it is on small echo lines.
        let text = '(' . errorGroup . ') ' . text

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction
