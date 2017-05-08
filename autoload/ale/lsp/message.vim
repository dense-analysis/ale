" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol message implementations
"
" Messages in this movie will be returned in the format
" [is_notification, method_name, params?]

function! ale#lsp#message#Initialize(root_uri) abort
    " TODO: Define needed capabilities.
    return [0, 'initialize', {
    \   'processId': getpid(),
    \   'rootUri': a:root_uri,
    \   'capabilities': {},
    \}]
endfunction

function! ale#lsp#message#Initialized() abort
    return [1, 'initialized']
endfunction

function! ale#lsp#message#Shutdown() abort
    return [0, 'shutdown']
endfunction

function! ale#lsp#message#Exit() abort
    return [1, 'exit']
endfunction

function! ale#lsp#message#DidOpen(uri, language_id, version, text) abort
    return [1, 'textDocument/didOpen', {
    \   'textDocument': {
    \       'uri': a:uri,
    \       'languageId': a:language_id,
    \       'version': a:version,
    \       'text': a:text,
    \   },
    \}]
endfunction

function! ale#lsp#message#DidChange(uri, version, text) abort
    " For changes, we simply send the full text of the document to the server.
    return [1, 'textDocument/didChange', {
    \   'textDocument': {
    \       'uri': a:uri,
    \       'version': a:version,
    \   },
    \   'contentChanges': [{'text': a:text}]
    \}]
endfunction

function! ale#lsp#message#DidSave(uri) abort
    return [1, 'textDocument/didSave', {
    \   'textDocument': {
    \       'uri': a:uri,
    \   },
    \}]
endfunction

function! ale#lsp#message#DidClose(uri) abort
    return [1, 'textDocument/didClose', {
    \   'textDocument': {
    \       'uri': a:uri,
    \   },
    \}]
endfunction
