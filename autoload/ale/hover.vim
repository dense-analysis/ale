" Author: w0rp <devw0rp@gmail.com>
" Description: Hover support for LSP linters.

let s:hover_map = {}

" Used to get the hover map in tests.
function! ale#hover#GetMap() abort
    return deepcopy(s:hover_map)
endfunction

" Used to set the hover map in tests.
function! ale#hover#SetMap(map) abort
    let s:hover_map = a:map
endfunction

function! ale#hover#ClearLSPData() abort
    let s:hover_map = {}
endfunction

function! ale#hover#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') is# 'quickinfo'
    \&& has_key(s:hover_map, a:response.request_seq)
        let l:options = remove(s:hover_map, a:response.request_seq)

        if get(a:response, 'success', v:false) is v:true
        \&& get(a:response, 'body', v:null) isnot v:null
            call ale#util#ShowMessage(a:response.body.displayString)
        endif
    endif
endfunction

function! ale#hover#HandleLSPResponse(conn_id, response) abort
    if has_key(a:response, 'id')
    \&& has_key(s:hover_map, a:response.id)
        let l:options = remove(s:hover_map, a:response.id)

        let l:buffer = bufnr('')
        let [l:line, l:column] = getcurpos()[1:2]
        let l:end = len(getline(l:line))

        if l:buffer isnot l:options.buffer
        \|| l:line isnot l:options.line
        \|| min([l:column, l:end]) isnot min([l:options.column, l:end])
            " Cancel display the message if the cursor has moved.
            return
        endif

        " The result can be a Dictionary item, a List of the same, or null.
        let l:result = get(a:response, 'result', v:null)

        if l:result is v:null
            return
        endif

        let l:result = l:result.contents

        if type(l:result) is type('')
             " The result can be just a string.
             let l:result = [l:result]
        endif

        if type(l:result) is type({})
            " If the result is an object, then it's markup content.
            let l:result = [l:result.value]
        endif

        if type(l:result) is type([])
            " Replace objects with text values.
            call map(l:result, 'type(v:val) is type('''') ? v:val : v:val.value')
            let l:str = join(l:result, "\n")
            let l:str = substitute(l:str, '^\s*\(.\{-}\)\s*$', '\1', '')

            if !empty(l:str)
                call ale#util#ShowMessage(l:str)
            endif
        endif
    endif
endfunction

function! s:ShowDetails(linter) abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getcurpos()[1:2]

    let l:Callback = a:linter.lsp is# 'tsserver'
    \   ? function('ale#hover#HandleTSServerResponse')
    \   : function('ale#hover#HandleLSPResponse')

    let l:lsp_details = ale#linter#StartLSP(l:buffer, a:linter, l:Callback)

    if empty(l:lsp_details)
        return 0
    endif

    let l:id = l:lsp_details.connection_id
    let l:root = l:lsp_details.project_root

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#Quickinfo(
        \   l:buffer,
        \   l:line,
        \   l:column
        \)
    else
        " Send a message saying the buffer has changed first, or the
        " hover position probably won't make sense.
        call ale#lsp#Send(l:id, ale#lsp#message#DidChange(l:buffer), l:root)

        let l:column = min([l:column, len(getline(l:line))])

        let l:message = ale#lsp#message#Hover(l:buffer, l:line, l:column)
    endif

    let l:request_id = ale#lsp#Send(l:id, l:message, l:root)

    let s:hover_map[l:request_id] = {
    \   'buffer': l:buffer,
    \   'line': l:line,
    \   'column': l:column,
    \}
endfunction

function! ale#hover#Show() abort
    for l:linter in ale#linter#Get(&filetype)
        if !empty(l:linter.lsp)
            call s:ShowDetails(l:linter)
        endif
    endfor
endfunction
