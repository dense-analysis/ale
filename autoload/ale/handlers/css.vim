scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Description: Error handling for CSS linters.

function! ale#handlers#css#HandleCSSLintFormat(buffer, lines) abort
    " Matches patterns line the following:
    "
    " something.css: line 2, col 1, Error - Expected RBRACE at line 2, col 1. (errors)
    " something.css: line 2, col 5, Warning - Expected (inline | block | list-item | inline-block | table | inline-table | table-row-group | table-header-group | table-footer-group | table-row | table-column-group | table-column | table-cell | table-caption | grid | inline-grid | run-in | ruby | ruby-base | ruby-text | ruby-base-container | ruby-text-container | contents | none | -moz-box | -moz-inline-block | -moz-inline-box | -moz-inline-grid | -moz-inline-stack | -moz-inline-table | -moz-grid | -moz-grid-group | -moz-grid-line | -moz-groupbox | -moz-deck | -moz-popup | -moz-stack | -moz-marker | -webkit-box | -webkit-inline-box | -ms-flexbox | -ms-inline-flexbox | flex | -webkit-flex | inline-flex | -webkit-inline-flex) but found 'wat'. (known-properties)
    "
    " These errors can be very massive, so the type will be moved to the front
    " so you can actually read the error type.
    let l:pattern = '\v^.*: line (\d+), col (\d+), (Error|Warning) - (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:text = l:match[4]
        let l:type = l:match[3]

        let l:group_match = matchlist(l:text, '\v^(.+) \((.+)\)$')

        " Put the error group at the front, so we can see what kind of error
        " it is on small echo lines.
        if !empty(l:group_match)
            let l:text = '(' . l:group_match[2] . ') ' . l:group_match[1]
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#css#HandleStyleLintFormat(buffer, lines) abort
    let l:exception_pattern = '\v^Error:'

    for l:line in a:lines[:10]
        if len(matchlist(l:line, l:exception_pattern)) > 0
            return [{
            \   'lnum': 1,
            \   'text': 'stylelint exception thrown (type :ALEDetail for more information)',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    " Matches patterns line the following:
    "
    " src/main.css
    "  108:10  ✖  Unexpected leading zero         number-leading-zero
    "  116:20  ✖  Expected a trailing semicolon   declaration-block-trailing-semicolon
    let l:pattern = '\v^.* (\d+):(\d+) \s+(\S+)\s+ (.*[^ ])\s+([^ ]+)\s*$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:match[3] ==# '✖' ? 'E' : 'W',
        \   'text': l:match[4] . ' [' . l:match[5] . ']',
        \})
    endfor

    return l:output
endfunction
