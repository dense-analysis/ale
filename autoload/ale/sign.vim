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

" Given a list of lines for sign output, return a List of pairs [line, id]
function! ale#sign#ParseSigns(line_list) abort
    " Matches output like :
    " line=4  id=1  name=ALEErrorSign
    " строка=1  id=1000001  имя=ALEErrorSign
    " 行=1  識別子=1000001  名前=ALEWarningSign
    " línea=12 id=1000001 nombre=ALEWarningSign
    " riga=1 id=1000001, nome=ALEWarningSign
    let l:pattern = '^.*=\(\d\+\).*=\(\d\+\).*=ALE\(Error\|Warning\|Dummy\)Sign'

    let l:result = []

    for l:line in a:line_list
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) > 0
            call add(l:result, [str2nr(l:match[1]), str2nr(l:match[2])])
        endif
    endfor

    return l:result
endfunction

function! ale#sign#FindCurrentSigns(buffer) abort
    let l:line_list = ale#sign#ReadSigns(a:buffer)

    return ale#sign#ParseSigns(l:line_list)
endfunction

" Given a loclist, group the List into with one List per line.
function! s:GroupSigns(loclist) abort
    let l:signlist = []
    let l:last_lnum = -1

    for l:obj in a:loclist
        " Create a new sub-List when we hit a new line.
        if l:obj.lnum != l:last_lnum
            call add(l:signlist, [])
        endif

        call add(l:signlist[-1], l:obj)
        let l:last_lnum = l:obj.lnum
    endfor

    return l:signlist
endfunction

function! s:IsDummySignSet(current_id_list) abort
    for [l:line, l:id] in a:current_id_list
        if l:id == g:ale_sign_offset
            return 1
        endif

        if l:line > 1
            return 0
        endif
    endfor

    return 0
endfunction

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(buffer, loclist) abort
    let l:signlist = s:GroupSigns(a:loclist)

    " Find the current markers
    let l:current_id_list = ale#sign#FindCurrentSigns(a:buffer)
    " Check if we set the dummy sign already.
    let l:dummy_sign_set = s:IsDummySignSet(l:current_id_list)

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
    for [l:line, l:current_id] in l:current_id_list
        if l:current_id != g:ale_sign_offset
            exec 'sign unplace ' . l:current_id . ' buffer=' . a:buffer
        endif
    endfor

    " Add the new signs,
    for l:index in range(0, len(l:signlist) - 1)
        let l:sign_id = l:index + g:ale_sign_offset + 1
        let l:sublist = l:signlist[l:index]
        let l:type = !empty(filter(copy(l:sublist), 'v:val.type ==# ''E'''))
        \   ? 'ALEErrorSign'
        \   : 'ALEWarningSign'

        " Save the sign IDs we are setting back on our loclist objects.
        " These IDs will be used to preserve items which are set many times.
        for l:obj in l:sublist
            let l:obj.sign_id = l:sign_id
        endfor

        let l:sign_line = 'sign place ' . l:sign_id
            \. ' line=' . l:sublist[0].lnum
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
