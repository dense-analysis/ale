" Author: w0rp <devw0rp@gmail.com>
" Description: Error handling for flake8, etc.

let s:end_col_pattern_map = {
\   'F405': '\(.\+\) may be undefined',
\   'F821': 'undefined name ''\([^'']\+\)''',
\   'F999': '^''\([^'']\+\)''',
\   'F841': 'local variable ''\([^'']\+\)''',
\}

function! ale#handlers#python#HandlePEP8Format(buffer, lines) abort
    for l:line in a:lines[:10]
        if match(l:line, '^Traceback') >= 0
            return [{
            \   'lnum': 1,
            \   'text': 'An exception was thrown. See :ALEDetail',
            \   'detail': join(a:lines, "\n"),
            \}]
        endif
    endfor

    " Matches patterns line the following:
    "
    " Matches patterns line the following:
    "
    " stdin:6:6: E111 indentation is not a multiple of four
    " test.yml:35: [EANSIBLE0002] Trailing whitespace
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):?(\d+)?: \[?([[:alnum:]]+)\]? (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:code = l:match[3]

        if (l:code ==# 'W291' || l:code ==# 'W293' || l:code ==# 'EANSIBLE002')
        \ && !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        if l:code ==# 'I0011'
            " Skip 'Locally disabling' message
             continue
        endif

        let l:item = {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:code . ': ' . l:match[4],
        \   'type': l:code[:0] ==# 'E' ? 'E' : 'W',
        \}

        let l:end_col_pattern = get(s:end_col_pattern_map, l:code, '')

        if !empty(l:end_col_pattern)
            let l:end_col_match = matchlist(l:match[4], l:end_col_pattern)

            if !empty(l:end_col_match)
                let l:item.end_col = l:item.col + len(l:end_col_match[1]) - 1
            endif
        endif

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

" Given a buffer number and a command name, find the path to the executable.
" First search on a virtualenv for Python, if nothing is found, try the global
" command. Returns an empty string if cannot find the executable
function! ale#handlers#python#GetExecutable(buffer, cmd_name) abort
    let l:virtualenv = ale#python#FindVirtualenv(a:buffer)

    if !empty(l:virtualenv)
        let l:ve_executable = l:virtualenv . '/bin/' . a:cmd_name

        if executable(l:ve_executable)
            return l:ve_executable
        endif
    endif

    if executable(a:cmd_name)
        return a:cmd_name
    endif

    return ''
endfunction
