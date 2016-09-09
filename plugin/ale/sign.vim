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

    for i in range(0, len(a:loclist) - 1)
        let obj = a:loclist[i]
        let name = obj['type'] ==# 'W' ? 'ALEWarningSign' : 'ALEErrorSign'

        let sign_line = 'sign place ' . (i + 1)
            \. ' line=' . obj['lnum']
            \. ' name=' . name
            \. ' buffer=' . obj['bufnr']

        exec sign_line
    endfor
endfunction
