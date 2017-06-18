scriptencoding utf8
" Author: w0rp <devw0rp@gmail.com>
" Description: Draws error and warning signs into signcolumn

let b:dummy_sign_set_map = {}

if !hlexists('ALEErrorSign')
    highlight link ALEErrorSign error
endif

if !hlexists('ALEStyleErrorSign')
    highlight link ALEStyleErrorSign ALEErrorSign
endif

if !hlexists('ALEWarningSign')
    highlight link ALEWarningSign todo
endif

if !hlexists('ALEStyleWarningSign')
    highlight link ALEStyleWarningSign ALEWarningSign
endif

if !hlexists('ALEInfoSign')
    highlight link ALEInfoSign ALEWarningSign
endif

if !hlexists('ALESignColumnWithErrors')
    highlight link ALESignColumnWithErrors error
endif

if !hlexists('ALESignColumnWithoutErrors')
    function! s:SetSignColumnWithoutErrorsHighlight() abort
        redir => l:output
            silent highlight SignColumn
        redir end

        let l:highlight_syntax = join(split(l:output)[2:])

        let l:match = matchlist(l:highlight_syntax, '\vlinks to (.+)$')

        if !empty(l:match)
            execute 'highlight link ALESignColumnWithoutErrors ' . l:match[1]
        elseif l:highlight_syntax !=# 'cleared'
            execute 'highlight ALESignColumnWithoutErrors ' . l:highlight_syntax
        endif
    endfunction

    call s:SetSignColumnWithoutErrorsHighlight()
    delfunction s:SetSignColumnWithoutErrorsHighlight
endif

" Signs show up on the left for error markers.
execute 'sign define ALEErrorSign text=' . g:ale_sign_error
\   . ' texthl=ALEErrorSign linehl=ALEErrorLine'
execute 'sign define ALEStyleErrorSign text=' . g:ale_sign_style_error
\   . ' texthl=ALEStyleErrorSign linehl=ALEErrorLine'
execute 'sign define ALEWarningSign text=' . g:ale_sign_warning
\   . ' texthl=ALEWarningSign linehl=ALEWarningLine'
execute 'sign define ALEStyleWarningSign text=' . g:ale_sign_style_warning
\   . ' texthl=ALEStyleWarningSign linehl=ALEWarningLine'
execute 'sign define ALEInfoSign text=' . g:ale_sign_info
\   . ' texthl=ALEInfoSign linehl=ALEInfoLine'
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
    let l:pattern = '\v^.*\=(\d+).*\=(\d+).*\=(ALE[a-zA-Z]+Sign)'
    let l:result = []

    for l:line in a:line_list
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) > 0
            call add(l:result, [
            \   str2nr(l:match[1]),
            \   str2nr(l:match[2]),
            \   l:match[3],
            \])
        endif
    endfor

    return l:result
endfunction

function! ale#sign#FindCurrentSigns(buffer) abort
    let l:line_list = ale#sign#ReadSigns(a:buffer)

    return ale#sign#ParseSigns(l:line_list)
endfunction

" Given a loclist, group the List into with one List per line.
function! s:GroupLoclistItems(loclist) abort
    let l:grouped_items = []
    let l:last_lnum = -1

    for l:obj in a:loclist
        " Create a new sub-List when we hit a new line.
        if l:obj.lnum != l:last_lnum
            call add(l:grouped_items, [])
        endif

        call add(l:grouped_items[-1], l:obj)
        let l:last_lnum = l:obj.lnum
    endfor

    " Now we've gathered the items in groups, filter the groups down to
    " the groups containing at least one new item.
    let l:new_grouped_items = []

    for l:group in l:grouped_items
        for l:obj in l:group
            if !has_key(l:obj, 'sign_id')
                call add(l:new_grouped_items, l:group)
                break
            endif
        endfor
    endfor

    return l:new_grouped_items
endfunction

function! s:IsDummySignSet(current_id_list) abort
    for [l:line, l:id, l:name] in a:current_id_list
        if l:id == g:ale_sign_offset
            return 1
        endif

        if l:line > 1
            return 0
        endif
    endfor

    return 0
endfunction

function! s:SetDummySignIfNeeded(buffer, current_sign_list, new_signs) abort
    let l:is_dummy_sign_set = s:IsDummySignSet(a:current_sign_list)

    " If we haven't already set a dummy sign, and we have some previous signs
    " or always want a dummy sign, then set one, to keep the sign column open.
    if !l:is_dummy_sign_set && (a:new_signs || g:ale_sign_column_always)
        execute 'sign place ' .  g:ale_sign_offset
        \   . ' line=1 name=ALEDummySign buffer='
        \   . a:buffer

        let l:is_dummy_sign_set = 1
    endif

    return l:is_dummy_sign_set
endfunction

function! ale#sign#GetSignType(sublist) abort
    let l:highest_level = 100

    for l:item in a:sublist
        let l:level = (l:item.type ==# 'I' ? 2 : l:item.type ==# 'W')

        if get(l:item, 'sub_type', '') ==# 'style'
            let l:level += 10
        endif

        if l:level < l:highest_level
            let l:highest_level = l:level
        endif
    endfor

    if l:highest_level == 10
        return 'ALEStyleErrorSign'
    elseif l:highest_level == 11
        return 'ALEStyleWarningSign'
    elseif l:highest_level == 2
        return 'ALEInfoSign'
    elseif l:highest_level == 1
        return 'ALEWarningSign'
    endif

    return 'ALEErrorSign'
endfunction

function! ale#sign#SetSignColumnHighlight(has_problems) abort
    highlight clear SignColumn

    if a:has_problems
        highlight link SignColumn ALESignColumnWithErrors
    else
        highlight link SignColumn ALESignColumnWithoutErrors
    endif
endfunction

function! s:PlaceNewSigns(buffer, grouped_items, current_sign_offset) abort
    if g:ale_change_sign_column_color
        call ale#sign#SetSignColumnHighlight(!empty(a:grouped_items))
    endif

    let l:offset = a:current_sign_offset > 0
    \   ? a:current_sign_offset
    \   : g:ale_sign_offset

    " Add the new signs,
    for l:index in range(0, len(a:grouped_items) - 1)
        let l:sign_id = l:offset + l:index + 1
        let l:sublist = a:grouped_items[l:index]
        let l:type = ale#sign#GetSignType(a:grouped_items[l:index])

        " Save the sign IDs we are setting back on our loclist objects.
        " These IDs will be used to preserve items which are set many times.
        for l:obj in l:sublist
            let l:obj.sign_id = l:sign_id
        endfor

        execute 'sign place ' . l:sign_id
        \   . ' line=' . l:sublist[0].lnum
        \   . ' name=' . l:type
        \   . ' buffer=' . a:buffer
    endfor
endfunction

" Get items grouped by any current sign IDs they might have.
function! s:GetItemsWithSignIDs(loclist) abort
    let l:items_by_sign_id = {}

    for l:item in a:loclist
        if has_key(l:item, 'sign_id')
            if !has_key(l:items_by_sign_id, l:item.sign_id)
                let l:items_by_sign_id[l:item.sign_id] = []
            endif

            call add(l:items_by_sign_id[l:item.sign_id], l:item)
        endif
    endfor

    return l:items_by_sign_id
endfunction

" Given some current signs and a loclist, look for items with sign IDs,
" and change the line numbers for loclist items to match the signs.
function! s:UpdateLineNumbers(current_sign_list, items_by_sign_id) abort
    " Do nothing if there's nothing to work with.
    if empty(a:items_by_sign_id)
        return
    endif

    for [l:line, l:sign_id, l:name] in a:current_sign_list
        for l:obj in get(a:items_by_sign_id, l:sign_id, [])
            let l:obj.lnum = l:line
        endfor
    endfor
endfunction

" This function will set the signs which show up on the left.
function! ale#sign#SetSigns(buffer, loclist) abort
    if !bufexists(str2nr(a:buffer))
        " Stop immediately when attempting to set signs for a buffer which
        " does not exist.
        return
    endif

    " Find the current markers
    let l:current_sign_list = ale#sign#FindCurrentSigns(a:buffer)
    " Get a mapping from sign IDs to current loclist items which have them.
    let l:items_by_sign_id = s:GetItemsWithSignIDs(a:loclist)

    " Use sign information to update the line numbers for the loclist items.
    call s:UpdateLineNumbers(l:current_sign_list, l:items_by_sign_id)
    " Sort items again, as the line numbers could have changed.
    call sort(a:loclist, 'ale#util#LocItemCompare')

    let l:grouped_items = s:GroupLoclistItems(a:loclist)

    " Set the dummy sign if we need to.
    " This keeps the sign gutter open while we remove things, etc.
    let l:is_dummy_sign_set = s:SetDummySignIfNeeded(
    \   a:buffer,
    \   l:current_sign_list,
    \   !empty(l:grouped_items),
    \)

    " Now remove the previous signs. The dummy will hold the column open
    " while we add the new signs, if we had signs before.
    for [l:line, l:sign_id, l:name] in l:current_sign_list
        if l:sign_id != g:ale_sign_offset
        \&& !has_key(l:items_by_sign_id, l:sign_id)
            exec 'sign unplace ' . l:sign_id . ' buffer=' . a:buffer
        endif
    endfor

    " Compute a sign ID offset so we don't hit the same sign IDs again.
    let l:current_sign_offset = max(map(keys(l:items_by_sign_id), 'str2nr(v:val)'))

    call s:PlaceNewSigns(a:buffer, l:grouped_items, l:current_sign_offset)
endfunction

function! ale#sign#RemoveDummySignIfNeeded(buffer) abort
    if !g:ale_sign_column_always
        execute 'sign unplace ' . g:ale_sign_offset . ' buffer=' . a:buffer
    endif
endfunction
