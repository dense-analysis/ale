scriptencoding utf8
" Author: w0rp <devw0rp@gmail.com>
" Description: Draws error and warning signs into signcolumn

let b:dummy_sign_set_map = {}

if !hlexists('ALEErrorSign')
    highlight link ALEErrorSign error
endif

if !hlexists('ALEWarningSign')
    highlight link ALEWarningSign todo
endif

" Signs show up on the left for error markers.
execute 'sign define ALEErrorSign text=' . g:ale_sign_error
\   . ' texthl=ALEErrorSign'
execute 'sign define ALEWarningSign text=' . g:ale_sign_warning
\   . ' texthl=ALEWarningSign'
sign define ALEDummySign

" Read sign data for a buffer to a list of lines.
function! ale#sign#ReadSigns(buffer) abort
    redir => l:output
       silent exec 'sign place buffer=' . a:buffer
    redir end

    return split(l:output, "\n")
endfunction

" Given a list of lines for sign output, return a list of sign IDs
function! ale#sign#ParseSigns(line_list) abort
    " Matches output like :
    " line=4  id=1  name=ALEErrorSign
    " строка=1  id=1000001  имя=ALEErrorSign
    " 行=1  識別子=1000001  名前=ALEWarningSign
    " línea=12 id=1000001 nombre=ALEWarningSign
    " riga=1 id=1000001, nome=ALEWarningSign
    let l:pattern = '^.*=\d*\s\+.*=\(\d\+\)\,\?\s\+.*=ALE\(Warning\|Error\|Dummy\)Sign'


    let l:id_list = []

    for l:line in a:line_list
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) > 0
            call add(l:id_list, l:match[1] + 0)
        endif
    endfor

    return l:id_list
endfunction

function! ale#sign#FindCurrentSigns(buffer) abort
    let l:line_list = ale#sign#ReadSigns(a:buffer)

    return ale#sign#ParseSigns(l:line_list)
endfunction

" Given a loclist, combine the loclist into a list of signs such that only
" one sign appears per line. Error lines will take precedence.
" The loclist will have been previously sorted.
function! ale#sign#CombineSigns(loclist) abort
    let l:signlist = []

    for l:obj in a:loclist
        let l:should_append = 1

        if l:obj.lnum < 1
            " Skip warnings and errors at line 0, etc.
            continue
        endif

        if len(l:signlist) > 0 && l:signlist[-1].lnum == l:obj.lnum
            " We can't add the same line twice, because signs must be
            " unique per line.
            let l:should_append = 0

            if l:signlist[-1].type ==# 'W' && l:obj.type ==# 'E'
                " If we had a warning previously, but now have an error,
                " we replace the object to set an error instead.
                let l:signlist[-1] = l:obj
            endif
        endif

        if l:should_append
            call add(l:signlist, l:obj)
        endif
    endfor

    return l:signlist
endfunction

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(buffer, loclist) abort
    let l:signlist = ale#sign#CombineSigns(a:loclist)

    " Find the current markers
    let l:current_id_list = ale#sign#FindCurrentSigns(a:buffer)
    let l:dummy_sign_set = 0

    " Check if we set the dummy sign already.
    for l:current_id in l:current_id_list
        if l:current_id == g:ale_sign_offset
            let l:dummy_sign_set = 1
        endif
    endfor

    " If we haven't already set a dummy sign, and we have some previous signs
    " or always want a dummy sign, then set one, to keep the sign column open.
    if !l:dummy_sign_set && (len(l:signlist) > 0 || g:ale_sign_column_always)
        execute 'sign place ' .  g:ale_sign_offset
        \   . ' line=1 name=ALEDummySign buffer='
        \   . a:buffer

        let l:dummy_sign_set = 1
    endif

    " Now remove the previous signs. The dummy will hold the column open
    " while we add the new signs, if we had signs before.
    for l:current_id in l:current_id_list
        if l:current_id != g:ale_sign_offset
            exec 'sign unplace ' . l:current_id . ' buffer=' . a:buffer
        endif
    endfor

    " Add the new signs,
    for l:index in range(0, len(l:signlist) - 1)
        let l:sign = l:signlist[l:index]
        let l:type = l:sign['type'] ==# 'W' ? 'ALEWarningSign' : 'ALEErrorSign'

        let l:sign_line = 'sign place ' . (l:index + g:ale_sign_offset + 1)
            \. ' line=' . l:sign['lnum']
            \. ' name=' . l:type
            \. ' buffer=' . a:buffer

        exec l:sign_line
    endfor

    " Remove the dummy sign now we've updated the signs, unless we want
    " to keep it, which will keep the sign column open even when there are
    " no warnings or errors.
    if l:dummy_sign_set && !g:ale_sign_column_always
        execute 'sign unplace ' . g:ale_sign_offset . ' buffer=' . a:buffer
    endif
endfunction
