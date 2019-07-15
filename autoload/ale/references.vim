let s:references_map = {}

let g:ale_use_quickfix_findref = get(g:, 'ale_use_quickfix_findref', 0)

" Used to get the references map in tests.
function! ale#references#GetMap() abort
    return deepcopy(s:references_map)
endfunction

" Used to set the references map in tests.
function! ale#references#SetMap(map) abort
    let s:references_map = a:map
endfunction

function! ale#references#ClearLSPData() abort
    let s:references_map = {}
endfunction

function! ale#references#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') is# 'references'
    \&& has_key(s:references_map, a:response.request_seq)
        let l:options = remove(s:references_map, a:response.request_seq)

        if get(a:response, 'success', v:false) is v:true
            let l:item_list = []

            for l:response_item in a:response.body.refs
                call add(l:item_list, {
                \ 'filename': l:response_item.file,
                \ 'line': l:response_item.start.line,
                \ 'column': l:response_item.start.offset,
                \ 'match': substitute(l:response_item.lineText, '^\s*\(.\{-}\)\s*$', '\1', ''),
                \})
            endfor

            if empty(l:item_list)
                call ale#util#Execute('echom ''No references found.''')
            else
                call ale#preview#ShowSelection(l:item_list, l:options)
            endif
        endif
    endif
endfunction

function! ale#references#HandleLSPResponse(conn_id, response) abort
    if has_key(a:response, 'id')
    \&& has_key(s:references_map, a:response.id)
        let l:options = remove(s:references_map, a:response.id)

        " The result can be a Dictionary item, a List of the same, or null.
        let l:result = get(a:response, 'result', [])
        let l:item_list = []

        if type(l:result) is v:t_list
            for l:response_item in l:result
                let l:col = l:response_item.range.start.character + 1
                let l:lnum = l:response_item.range.start.line + 1
                let l:filename = ale#path#FromURI(l:response_item.uri)

                if g:ale_use_quickfix_findref
                    let l:cwd = getcwd()
                    call add(l:item_list, {
                    \ 'filename': substitute(l:filename, l:cwd . '/', "", ""),
                    \ 'lnum': l:lnum,
                    \ 'col': l:col,
                    \ 'text': system('sed "' . l:lnum . 'q;d" ' . l:filename),
                    \ 'vcol': 1,
                    \})
                else
                    call add(l:item_list, {
                    \ 'filename': l:filename,
                    \ 'line': l:lnum,
                    \ 'column': l:col,
                    \})
                endif
            endfor
        else
            if type(l:result) is v:t_list
                for l:response_item in l:result
                endfor
            endif
        endif

        if empty(l:item_list)
            call ale#util#Execute('echom ''No references found.''')
        else
            if g:ale_use_quickfix_findref
                call setqflist([], 'r')
                call setqflist(l:item_list, 'a')
                execute "botright copen"
            else
                call ale#preview#ShowSelection(l:item_list, l:options)
            endif
        endif
    endif
endfunction

function! s:OnReady(line, column, options, linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if !ale#lsp#HasCapability(l:id, 'references')
        return
    endif

    let l:buffer = a:lsp_details.buffer

    let l:Callback = a:linter.lsp is# 'tsserver'
    \   ? function('ale#references#HandleTSServerResponse')
    \   : function('ale#references#HandleLSPResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#References(
        \   l:buffer,
        \   a:line,
        \   a:column
        \)
    else
        " Send a message saying the buffer has changed first, or the
        " references position probably won't make sense.
        call ale#lsp#NotifyForChanges(l:id, l:buffer)

        let l:message = ale#lsp#message#References(l:buffer, a:line, a:column)
    endif

    let l:request_id = ale#lsp#Send(l:id, l:message)

    let s:references_map[l:request_id] = {
    \ 'use_relative_paths': has_key(a:options, 'use_relative_paths') ? a:options.use_relative_paths : 0
    \}
endfunction

function! ale#references#Find(...) abort
    let l:options = {}

    if len(a:000) > 0
        for l:option in a:000
            if l:option is? '-relative'
                let l:options.use_relative_paths = 1
            endif
        endfor
    endif

    let l:buffer = bufnr('')
    let [l:line, l:column] = getpos('.')[1:2]
    let l:column = min([l:column, len(getline(l:line))])
    let l:Callback = function('s:OnReady', [l:line, l:column, l:options])

    for l:linter in ale#linter#Get(&filetype)
        if !empty(l:linter.lsp)
            call ale#lsp_linter#StartLSP(l:buffer, l:linter, l:Callback)
        endif
    endfor
endfunction
