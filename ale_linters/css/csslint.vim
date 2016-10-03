" Author: w0rp <devw0rp@gmail.com>
" Description: This file adds support for checking CSS code with csslint.

if exists('g:loaded_ale_linters_css_csslint')
    finish
endif

let g:loaded_ale_linters_css_csslint = 1

function! ale_linters#css#csslint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " something.css: line 2, col 1, Error - Expected RBRACE at line 2, col 1. (errors)
    " something.css: line 2, col 5, Warning - Expected (inline | block | list-item | inline-block | table | inline-table | table-row-group | table-header-group | table-footer-group | table-row | table-column-group | table-column | table-cell | table-caption | grid | inline-grid | run-in | ruby | ruby-base | ruby-text | ruby-base-container | ruby-text-container | contents | none | -moz-box | -moz-inline-block | -moz-inline-box | -moz-inline-grid | -moz-inline-stack | -moz-inline-table | -moz-grid | -moz-grid-group | -moz-grid-line | -moz-groupbox | -moz-deck | -moz-popup | -moz-stack | -moz-marker | -webkit-box | -webkit-inline-box | -ms-flexbox | -ms-inline-flexbox | flex | -webkit-flex | inline-flex | -webkit-inline-flex) but found 'wat'. (known-properties)
    "
    " These errors can be very massive, so the type will be moved to the front
    " so you can actually read the error type.
    let pattern = '^.*: line \(\d\+\), col \(\d\+\), \(Error\|Warning\) - \(.\+\) (\([^)]\+\))$'
    let output = []
    " Some errors have line numbers beyond the end of the file,
    " so we need to adjust them so they set the error at the last line
    " of the file instead.
    "
    " TODO: Find a faster way to compute this.
    let last_line_number = len(getbufline(a:buffer, 1, '$'))

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
        \   'lnum': min([l:match[1] + 0, last_line_number]),
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('css', {
\   'name': 'csslint',
\   'executable': 'csslint',
\   'command': g:ale#util#stdin_wrapper . ' .css csslint --format=compact',
\   'callback': 'ale_linters#css#csslint#Handle',
\})
