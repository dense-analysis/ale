" Author: w0rp <devw0rp@gmail.com>
" Description: Generic fixer functions for Python.

" Add blank lines before control statements.
function! ale#fixers#generic_python#AddLinesBeforeControlStatements(buffer, lines) abort
    let l:new_lines = []
    let l:last_indent_size = 0
    let l:last_line_is_blank = 0

    for l:line in a:lines
        let l:indent_size = len(matchstr(l:line, '^ *'))

        if !l:last_line_is_blank
        \&& l:indent_size <= l:last_indent_size
        \&& match(l:line, '\v^ *(return|if|for|while|break|continue)') >= 0
            call add(l:new_lines, '')
        endif

        call add(l:new_lines, l:line)
        let l:last_indent_size = l:indent_size
        let l:last_line_is_blank = empty(split(l:line))
    endfor

    return l:new_lines
endfunction
