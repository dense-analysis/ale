" Author: w0rp <devw0rp@gmail.com>

" Get the shell type for a buffer, based on the hashbang line.
function! ale#handlers#sh#GetShellType(buffer) abort
    let l:bang_line = get(getbufline(a:buffer, 1), 0, '')

    let l:command = ''

    " Take the shell executable from the hashbang, if we can.
    if l:bang_line[:1] is# '#!'
        " Remove options like -e, etc.
        let l:command = substitute(l:bang_line, ' --\?[a-zA-Z0-9]\+', '', 'g')
    " Otherwise, try to read a shellcheck diretive of the form:
    " # shellcheck shell=<shell>
    else
        let l:matches = matchlist(l:bang_line, '\v^#\s*shellcheck\s+shell\s*\=\s*(\S+)')
        if ! empty(l:matches)
            let l:command = l:matches[1]
        endif
    endif

    " If we couldn't find a hashbang, try the filetype
    if l:command is# ''
        let l:command = &filetype
    endif

    for l:possible_shell in ['bash', 'dash', 'ash', 'tcsh', 'csh', 'zsh', 'ksh', 'sh']
        if l:command =~# l:possible_shell . '\s*$'
            return l:possible_shell
        endif
    endfor

    return ''
endfunction
