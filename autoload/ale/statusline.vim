" Author: KabbAmine <amine.kabb@gmail.com>
" Description: Statusline related function(s)

function! ale#statusline#status() abort
    " Returns a formatted string that can be integrated in the
    " statusline

    let buf = bufnr('%')
    let bufLoclist = g:ale_buffer_loclist_map

    if !has_key(bufLoclist, buf)
        return ''
    endif

    let errors = 0
    let warnings = 0
    for e in bufLoclist[buf]
        if e.type ==# 'E'
            let errors += 1
        else
            let warnings += 1
        endif
    endfor

    let errors = errors ? printf(g:ale_statusline_format[0], errors) : ''
    let warnings = warnings ? printf(g:ale_statusline_format[1], warnings) : ''
    let no_errors = g:ale_statusline_format[2]

    " Different formats if no errors or no warnings
    if empty(errors) && empty(warnings)
        let res = no_errors
    elseif !empty(errors) && !empty(warnings)
        let res = printf('%s %s', errors, warnings)
    else
        let res = empty(errors) ? warnings : errors
    endif

    return res
endfunction

