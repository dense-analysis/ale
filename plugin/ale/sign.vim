if exists('g:loaded_ale_sign')
    finish
endif

let g:loaded_ale_sign = 1

if !hlexists('ALEErrorSign')
    highlight link ALErrorSign error
endif

if !hlexists('ALEWarningSign')
    highlight link ALEWarningSign todo
endif

if !hlexists('ALEError')
    highlight link ALEError SpellBad
endif

if !hlexists('ALEWarning')
    highlight link ALEWarning SpellCap
endif

" Signs show up on the left for error markers.
sign define ALEErrorSign text=>> texthl=ALEErrorSign
sign define ALEWarningSign text=-- texthl=ALEWarningSign

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(loclist)
    let buffer = bufnr('%')

    exec 'sign unplace * buffer=' . buffer

    let signlist = []

    for obj in a:loclist
        let should_append = 1

        if len(signlist) > 0 && signlist[-1].lnum == obj.lnum
            " We can't add the same line twice, because signs must be
            " unique per line.
            let should_append = 0

            if signlist[-1].type ==# 'W' && obj.type ==# 'E'
                " If we had a warning previously, but now have an error,
                " we replace the object to set an error instead.
                let signlist[-1] = obj
            endif
        endif

        if should_append
            call add(signlist, obj)
        endif
    endfor

    for i in range(0, len(signlist) - 1)
        let obj = signlist[i]
        let name = obj['type'] ==# 'W' ? 'ALEWarningSign' : 'ALEErrorSign'

        let sign_line = 'sign place ' . (i + 1)
            \. ' line=' . obj['lnum']
            \. ' name=' . name
            \. ' buffer=' . buffer

        exec sign_line
    endfor
endfunction
