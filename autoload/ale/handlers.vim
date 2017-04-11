scriptencoding utf-8
" Author: w0rp <devw0rp@gmail.com>
" Description: This file defines some standard error format handlers. Any
"   linter which outputs warnings and errors in a format accepted by one of
"   these functions can simply use one of these pre-defined error handlers.

let s:path_pattern = '[a-zA-Z]\?\\\?:\?[[:alnum:]/\.\-_]\+'

function! s:HandleUnixFormat(buffer, lines, type) abort
    " Matches patterns line the following:
    "
    " file.go:27: missing argument for Printf("%s"): format reads arg 2, have only 1 args
    " file.go:53:10: if block ends with a return statement, so drop this else and outdent its block (move short variable declaration to its own line if necessary)
    " file.go:5:2: expected declaration, found 'STRING' "log"
    let l:pattern = '^' . s:path_pattern . ':\(\d\+\):\?\(\d\+\)\?:\? \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': a:type,
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#HandleUnixFormatAsError(buffer, lines) abort
    return s:HandleUnixFormat(a:buffer, a:lines, 'E')
endfunction

function! ale#handlers#HandleUnixFormatAsWarning(buffer, lines) abort
    return s:HandleUnixFormat(a:buffer, a:lines, 'W')
endfunction

function! ale#handlers#HandleCppCheckFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    " [test.cpp:5]: (error) Array 'a[10]' accessed at index 10, which is out of bounds
    let l:pattern = '^\[.\{-}:\(\d\+\)\]: (\(.\{-}\)) \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': 0,
        \   'text': l:match[3] . ' (' . l:match[2] . ')',
        \   'type': l:match[2] ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#HandlePEP8Format(buffer, lines) abort
    " Matches patterns line the following:
    "
    " Matches patterns line the following:
    "
    " stdin:6:6: E111 indentation is not a multiple of four
    " test.yml:35: [EANSIBLE0002] Trailing whitespace
    let l:pattern = '^' . s:path_pattern . ':\(\d\+\):\?\(\d\+\)\?: \[\?\(\([[:alpha:]]\)[[:alnum:]]\+\)\]\? \(.*\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:code = l:match[3]
        if (l:code ==# 'W291' || l:code ==# 'W293' || l:code ==# 'EANSIBLE002')
                    \ && !g:ale_warn_about_trailing_whitespace
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        if l:code ==# 'I0011'
            " Skip 'Locally disabling' message
             continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:code . ': ' . l:match[5],
        \   'type': l:match[4] ==# 'E' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#HandleCSSLintFormat(buffer, lines) abort
    " Matches patterns line the following:
    "
    " something.css: line 2, col 1, Error - Expected RBRACE at line 2, col 1. (errors)
    " something.css: line 2, col 5, Warning - Expected (inline | block | list-item | inline-block | table | inline-table | table-row-group | table-header-group | table-footer-group | table-row | table-column-group | table-column | table-cell | table-caption | grid | inline-grid | run-in | ruby | ruby-base | ruby-text | ruby-base-container | ruby-text-container | contents | none | -moz-box | -moz-inline-block | -moz-inline-box | -moz-inline-grid | -moz-inline-stack | -moz-inline-table | -moz-grid | -moz-grid-group | -moz-grid-line | -moz-groupbox | -moz-deck | -moz-popup | -moz-stack | -moz-marker | -webkit-box | -webkit-inline-box | -ms-flexbox | -ms-inline-flexbox | flex | -webkit-flex | inline-flex | -webkit-inline-flex) but found 'wat'. (known-properties)
    "
    " These errors can be very massive, so the type will be moved to the front
    " so you can actually read the error type.
    let l:pattern = '^.*: line \(\d\+\), col \(\d\+\), \(Error\|Warning\) - \(.\+\) (\([^)]\+\))$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[4]
        let l:type = l:match[3]
        let l:errorGroup = l:match[5]

        " Put the error group at the front, so we can see what kind of error
        " it is on small echo lines.
        let l:text = '(' . l:errorGroup . ') ' . l:text

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#HandleStyleLintFormat(buffer, lines) abort
    " Matches patterns line the following:
    "
    " src/main.css
    "  108:10  ✖  Unexpected leading zero         number-leading-zero
    "  116:20  ✖  Expected a trailing semicolon   declaration-block-trailing-semicolon
    let l:pattern = '^.* \(\d\+\):\(\d\+\) \s\+\(\S\+\)\s\+ \(\u.\+\) \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:type = l:match[3] ==# '✖' ? 'E' : 'W'
        let l:text = l:match[4] . '[' . l:match[5] . ']'

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#HandleGhcFormat(buffer, lines) abort
    " Look for lines like the following.
    "
    "Appoint/Lib.hs:8:1: warning:
    "Appoint/Lib.hs:8:1:
    let l:pattern = '^[^:]\+:\(\d\+\):\(\d\+\):\(.*\)\?$'
    let l:output = []

    let l:corrected_lines = []
    for l:line in a:lines
        if len(matchlist(l:line, l:pattern)) > 0
            call add(l:corrected_lines, l:line)
        elseif l:line ==# ''
            call add(l:corrected_lines, l:line)
        else
            if len(l:corrected_lines) > 0
                let l:line = substitute(l:line, '\v^\s+', ' ', '')
                let l:corrected_lines[-1] .= l:line
            endif
        endif
    endfor

    for l:line in l:corrected_lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:errors = matchlist(l:match[3], '\(warning:\|error:\)\(.*\)')

        if len(l:errors) > 0
          let l:type = l:errors[1]
          let l:text = l:errors[2]
        else
          let l:type = ''
          let l:text = l:match[3]
        endif

        let l:type = l:type ==# '' ? 'E' : toupper(l:type[0])

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': l:type,
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction
