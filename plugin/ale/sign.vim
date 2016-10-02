if exists('g:loaded_ale_sign')
    finish
endif

let g:loaded_ale_sign = 1

if !hlexists('ALEErrorSign')
    highlight link ALEErrorSign error
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

" Global variables for signs
let g:ale_sign_error = get(g:, 'ale_sign_error', '>>')
let g:ale_sign_warning = get(g:, 'ale_sign_error', '--')

" Signs show up on the left for error markers.
execute 'sign define ALEErrorSign text=' . g:ale_sign_error
			\	. ' texthl=ALEErrorSign'
execute 'sign define ALEWarningSign text=' . g:ale_sign_warning
			\	. ' texthl=ALEWarningSign'

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(buffer, loclist)
    exec 'sign unplace * buffer=' . a:buffer

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

    call ale#sign#InsertDummy(len(signlist))

    for i in range(0, len(signlist) - 1)
        let obj = signlist[i]
        let name = obj['type'] ==# 'W' ? 'ALEWarningSign' : 'ALEErrorSign'

        let sign_line = 'sign place ' . (i + 1)
            \. ' line=' . obj['lnum']
            \. ' name=' . name
            \. ' buffer=' . a:buffer

        exec sign_line
    endfor
endfunction

" Show signd gutter if there is no signs and g:ale_sign_column_alwas is set to 1
function! ale#sign#InsertDummy(no_signs)
    if g:ale_sign_column_always == 1 && a:no_signs == 0
        sign define ale_keep_open_dummy
        execute 'sign place 9999 line=1 name=ale_keep_open_dummy buffer=' . bufnr('')
    endif
endfunction

