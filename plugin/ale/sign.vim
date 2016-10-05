" Author: w0rp <devw0rp@gmail.com>
" Description: Draws error and warning signs into signcolumn

if exists('g:loaded_ale_sign')
    finish
endif

let g:loaded_ale_sign = 1
let b:dummy_sign_set_map = {}

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
let g:ale_sign_warning = get(g:, 'ale_sign_warning', '--')
" An offset which can be set for sign IDs.
" This ID can be changed depending on what IDs are set for other plugins.
" The dummy sign will use the ID exactly equal to the offset.
let g:ale_sign_offset = get(g:, 'ale_sign_offset', 1000000)

" Signs show up on the left for error markers.
execute 'sign define ALEErrorSign text=' . g:ale_sign_error
\   . ' texthl=ALEErrorSign'
execute 'sign define ALEWarningSign text=' . g:ale_sign_warning
\   . ' texthl=ALEWarningSign'
sign define ALEDummySign

function! ale#sign#FindCurrentSigns(buffer)
    " Matches output like :
    " line=4  id=1  name=ALEErrorSign
    " строка=1  id=1000001  имя=ALEErrorSign
    let pattern = 'id=\(\d\+\).*=ALE\(Warning\|Error\)Sign'

    redir => output
       silent exec 'sign place buffer=' . a:buffer
    redir END

    let id_list = []

    for line in split(output, "\n")
        let match = matchlist(line, pattern)

        if len(match) > 0
            call add(id_list, match[1] + 0)
        endif
    endfor

    return id_list
endfunction

" Given a loclist, combine the loclist into a list of signs such that only
" one sign appears per line. Error lines will take precedence.
" The loclist will have been previously sorted.
function! ale#sign#CombineSigns(loclist)
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

    return signlist
endfunction

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(buffer, loclist)
    let signlist = ale#sign#CombineSigns(a:loclist)

    if len(signlist) > 0 || g:ale_sign_column_always
        if !get(g:ale_buffer_sign_dummy_map, a:buffer, 0)
            " Insert a dummy sign if one is missing.
            execute 'sign place ' .  g:ale_sign_offset
            \   . ' line=1 name=ALEDummySign buffer='
            \   . a:buffer

            let g:ale_buffer_sign_dummy_map[a:buffer] = 1
        endif
    endif

    " Find the current signs with the markers we use.
    let current_id_list = ale#sign#FindCurrentSigns(a:buffer)

    " Remove those markers.
    for current_id in current_id_list
        exec 'sign unplace ' . current_id . ' buffer=' . a:buffer
    endfor

    " Now set all of the signs.
    for i in range(0, len(signlist) - 1)
        let obj = signlist[i]
        let name = obj['type'] ==# 'W' ? 'ALEWarningSign' : 'ALEErrorSign'

        let sign_line = 'sign place ' . (i + g:ale_sign_offset + 1)
            \. ' line=' . obj['lnum']
            \. ' name=' . name
            \. ' buffer=' . a:buffer

        exec sign_line
    endfor

    if !g:ale_sign_column_always && len(signlist) > 0
        if get(g:ale_buffer_sign_dummy_map, a:buffer, 0)
            execute 'sign unplace ' . g:ale_sign_offset . ' buffer=' . a:buffer

            let g:ale_buffer_sign_dummy_map[a:buffer] = 0
        endif
    endif
endfunction
