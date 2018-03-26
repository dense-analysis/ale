" Author: Zoltan Kalmar - https://github.com/kalmiz,
"         w0rp <devw0rp@gmail.com>
"         Nils Leuzinger - https://github.com/PawkyPenguin
" Description: Functions for usage with scalac-like linters

function! ale#scala#GetExecutableForLinter(buffer, linter) abort
    if index(split(getbufvar(a:buffer, '&filetype'), '\.'), 'sbt') >= 0
        " Don't check sbt files
        return ''
    endif

    return a:linter
endfunction

function! ale#scala#GetCommandForLinter(buffer, linter) abort
    let l:executable = ale#scala#GetExecutableForLinter(a:buffer, a:linter)

    if empty(l:executable)
        return ''
    endif

    return ale#Escape(l:executable) . ' -Ystop-after:parser %t'
endfunction
