" Author: rhysd <https://github.com/rhysd>
" Description: naga-cli linter for WGSL syntax.

call ale#Set('wgsl_naga_executable', 'naga')

function! ale_linters#wgsl#naga#HandleErrors(buffer, lines) abort
    let l:errors = []
    let l:current_error = v:null

    for l:line in a:lines
        if l:line =~# '^error: '
            let l:text = l:line[7:]
            let l:current_error = { 'text': l:text, 'type': 'E' }
            continue
        endif

        if l:current_error isnot v:null
            let l:matches = matchlist(l:line, '\v:(\d+):(\d+)$')

            if !empty(l:matches)
                let l:current_error.lnum = str2nr(l:matches[1])
                let l:current_error.col = str2nr(l:matches[2])
                call add(l:errors, l:current_error)
                let l:current_error = v:null
                continue
            endif
        endif
    endfor

    return l:errors
endfunction

call ale#linter#Define('wgsl', {
\   'name': 'naga',
\   'executable': {b -> ale#Var(b, 'wgsl_naga_executable')},
\   'output_stream': 'stderr',
\   'command': {b -> '%e --stdin-file-path %s'},
\   'callback': 'ale_linters#wgsl#naga#HandleErrors',
\})
