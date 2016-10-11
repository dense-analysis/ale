" Author: KabbAmine <amine.kabb@gmail.com>
" Description: Statusline related function(s)

function! ale#statusline#Status() abort
    " Returns a formatted string that can be integrated in the
    " statusline

    let l:buffer = bufnr('%')
    let l:loclist = g:ale_buffer_loclist_map

    if !has_key(l:loclist, l:buffer)
        return ''
    endif

    let l:errors = 0
    let l:warnings = 0
    for l:entry in l:loclist[l:buffer]
        if l:entry.type ==# 'E'
            let l:errors += 1
        else
            let l:warnings += 1
        endif
    endfor

    let l:errors = l:errors ? printf(g:ale_statusline_format[0], l:errors) : ''
    let l:warnings = l:warnings ? printf(g:ale_statusline_format[1], l:warnings) : ''
    let l:no_errors = g:ale_statusline_format[2]

    " Different formats if no errors or no warnings
    if empty(l:errors) && empty(l:warnings)
        let l:res = l:no_errors
    elseif !empty(l:errors) && !empty(l:warnings)
        let l:res = printf('%s %s', l:errors, l:warnings)
    else
        let l:res = empty(l:errors) ? l:warnings : l:errors
    endif

    return l:res
endfunction
