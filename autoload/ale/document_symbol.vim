" Author: Andrey Popp <8mayday@gmail.com>
" Description: Document Symbol support for LSP linters.

let s:document_symbol_map = {}

function s:HandleLSPResponse(conn_id, response) abort
    if has_key(a:response, 'id')
    \&& has_key(s:document_symbol_map, a:response.id)
        let l:options = remove(s:document_symbol_map, a:response.id)
        call call(l:options.callback, [a:response.result])
    endif
endfunction

function! s:OnReady(buffer, state, callback, linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if !ale#lsp#HasCapability(l:id, 'document_symbol')
        return
    endif

    if a:state.found_provider
        return
    endif
    let a:state.found_provider = 1
    let l:id = a:lsp_details.connection_id
    call ale#lsp#RegisterCallback(
        \l:id,
        \function('s:HandleLSPResponse')
        \)

    let l:message = ale#lsp#message#DocumentSymbol(a:buffer)
    let l:request_id = ale#lsp#Send(l:id, l:message)

    let s:document_symbol_map[l:request_id] = {'callback': a:callback}
endfunction

function! s:List(linter, buffer, state, callback) abort
    let l:Callback = function(
    \    's:OnReady',
    \    [a:buffer, a:state, a:callback]
    \  )
    call ale#lsp_linter#StartLSP(a:buffer, a:linter, l:Callback)
endfunction

function! ale#document_symbol#List(callback) abort
    let l:buffer = bufnr('')

    let l:state = {'found_provider': 0}

    for l:linter in ale#linter#Get(getbufvar(l:buffer, '&filetype'))
        if !empty(l:linter.lsp)
            call s:List(l:linter, l:buffer, l:state, a:callback)
        endif
    endfor
endfunction
