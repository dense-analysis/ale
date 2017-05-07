" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol client code

let g:ale_lsp_next_message_id = 1

function! ale#lsp#GetNextMessageID() abort
    " Use the current ID
    let l:id = g:ale_lsp_next_message_id

    " Increment the ID variable.
    let g:ale_lsp_next_message_id += 1

    " When the ID overflows, reset it to 1. By the time we hit the initial ID
    " again, the messages will be long gone.
    if g:ale_lsp_next_message_id < 1
        let g:ale_lsp_next_message_id = 1
    endif

    return l:id
endfunction

" (method_name, params)
function! ale#lsp#CreateMessage(method_name, ...) abort
    if a:0 > 1
        throw 'Too many arguments!'
    endif

    let l:obj = {
    \   'id': ale#lsp#GetNextMessageID(),
    \   'jsonrpc': '2.0',
    \   'method': a:method_name,
    \}

    if a:0 > 0
        let l:obj.params = a:1
    endif

    let l:body = json_encode(l:obj)

    return 'Content-Length: ' . strlen(l:body) . "\r\n\r\n" . l:body
endfunction

function! ale#lsp#ReadMessage(data) abort
    let l:header_end_index = match(a:data, "\r\n\r\n")

    if l:header_end_index < 0
        throw 'Invalid messaage: ' . string(a:data)
    endif

    return json_decode(a:data[l:header_end_index + 4:])
endfunction

" Constants for message severity codes.
let s:SEVERITY_ERROR = 1
let s:SEVERITY_WARNING = 2
let s:SEVERITY_INFORMATION = 3
let s:SEVERITY_HINT = 4

" Parse the message for textDocument/publishDiagnostics
function! ale#lsp#ReadDiagnostics(params) abort
    let l:filename = a:params.uri
    let l:loclist = []

    for l:diagnostic in a:params.diagnostics
        let l:severity = get(l:diagnostic, 'severity', 0)
        let l:loclist_item = {
        \   'message': l:diagnostic.message,
        \   'type': 'E',
        \   'lnum': l:diagnostic.range.start.line + 1,
        \   'col': l:diagnostic.range.start.character + 1,
        \   'end_lnum': l:diagnostic.range.end.line + 1,
        \   'end_col': l:diagnostic.range.end.character + 1,
        \}

        if l:severity == s:SEVERITY_WARNING
            let l:loclist_item.type = 'W'
        elseif l:severity == s:SEVERITY_INFORMATION
            " TODO: Use 'I' here in future.
            let l:loclist_item.type = 'W'
        elseif l:severity == s:SEVERITY_HINT
            " TODO: Use 'H' here in future
            let l:loclist_item.type = 'W'
        endif

        if has_key(l:diagnostic, 'code')
            let l:loclist_item.nr = l:diagnostic.code
        endif

        call add(l:loclist, l:loclist_item)
    endfor

    return [l:filename, l:loclist]
endfunction
