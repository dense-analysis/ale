let s:rename_map = {}

" Used to get the rename map in tests.
function! ale#rename#GetMap() abort
    return deepcopy(s:rename_map)
endfunction

" Used to set the rename map in tests.
function! ale#rename#SetMap(map) abort
    let s:rename_map = a:map
endfunction

function! ale#rename#ClearLSPData() abort
    let s:rename_map = {}
endfunction

function! s:ApplyRenameEdits(item_list) abort
    " TODO: implement...
endfunction

function! ale#rename#HandleTSServerResponse(conn_id, response) abort
    call ale#util#Execute('echom '')
    if get(a:response, 'command', '') is# 'rename'
    \&& has_key(s:rename_map, a:response.request_seq)
        call remove(s:rename_map, a:response.request_seq)
        if get(a:response, 'success', v:false) is v:true
            let l:item_list = []

            for l:response_item in a:response.body.refs
                call add(l:item_list, {
                \ 'filename': l:response_item.file,
                \ 'line': l:response_item.start.line,
                \ 'column': l:response_item.start.offset,
                \})
            endfor

            if empty(l:item_list)
                call ale#util#Execute('echom ''Could not rename.''')
            else
                call s:ApplyRenameEdits(l:item_list)
            endif
        endif
    endif
endfunction

function! ale#rename#HandleLSPResponse(conn_id, response) abort
    if has_key(a:response, 'id')
    \&& has_key(s:rename_map, a:response.id)
        call remove(s:rename_map, a:response.id)
        " The result can be a Dictionary item, a List of the same, or null.
        let l:result = get(a:response, 'result', [])
        let l:item_list = []

        for l:response_item in l:result
            call add(l:item_list, {
            \ 'filename': ale#path#FromURI(l:response_item.uri),
            \ 'line': l:response_item.range.start.line + 1,
            \ 'column': l:response_item.range.start.character + 1,
            \})
        endfor

        if empty(l:item_list)
            call ale#util#Execute('echom ''Could not rename.''')
        else
            call s:ApplyRenameEdits(l:item_list)
        endif
    endif
endfunction

function! s:OnReady(linter, lsp_details, line, column, new_name, ...) abort
    let l:buffer = a:lsp_details.buffer
    let l:id = a:lsp_details.connection_id

    let l:Callback = a:linter.lsp is# 'tsserver'
    \   ? function('ale#rename#HandleTSServerResponse')
    \   : function('ale#rename#HandleLSPResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#Rename(
        \   l:buffer,
        \   a:line,
        \   a:column,
        \   a:new_name
        \)
    else
        " Send a message saying the buffer has changed first, or the
        " rename position probably won't make sense.
        call ale#lsp#NotifyForChanges(l:id, l:buffer)

        let l:message = ale#lsp#message#Rename(
        \   l:buffer,
        \   a:line,
        \   a:column,
        \   a:new_name
        \)
    endif

    let l:request_id = ale#lsp#Send(l:id, l:message)

    let s:rename_map[l:request_id] = {}
endfunction

function! s:ExecuteRename(linter, new_name) abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getcurpos()[1:2]

    if a:linter.lsp isnot# 'tsserver'
        let l:column = min([l:column, len(getline(l:line))])
    endif

    let l:lsp_details = ale#lsp_linter#StartLSP(l:buffer, a:linter)

    if empty(l:lsp_details)
        return 0
    endif

    let l:id = l:lsp_details.connection_id

    call ale#lsp#WaitForCapability(l:id, 'rename', function('s:OnReady', [
    \   a:linter, l:lsp_details, l:line, l:column, a:new_name
    \]))
endfunction

function! ale#rename#Execute(...) abort
    let l:lsp_linters = []
    for l:linter in ale#linter#Get(&filetype)
        if !empty(l:linter.lsp)
           call add(l:lsp_linters, l:linter)
        endif
    endfor

    if !empty(l:lsp_linters)
        let l:prompt = 'new name: '
        let l:new_name = a:0 ? join(a:000) : input(l:prompt, expand('<cWORD>'))

        if !empty(l:new_name)
            for l:lsp_linter in l:lsp_linters
                call s:ExecuteRename(l:lsp_linter, l:new_name)
            endfor
        endif
    endif
endfunction
