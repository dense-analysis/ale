" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol message implementations

function! ale#lsp#message#CancelRequest(id) abort
    return ale#lsp#CreateMessage('$/cancelRequest', {'id': a:id})
endfunction

function! ale#lsp#message#Initialize(processId, rootUri) abort
    " TODO: Define needed capabilities.
    return ale#lsp#CreateMessage('initialize', {
    \   'processId': a:processId,
    \   'rootUri': a:rootUri,
    \   'capabilities': {},
    \})
endfunction

function! ale#lsp#message#Initialized() abort
    return ale#lsp#CreateMessage('initialized')
endfunction

function! ale#lsp#message#Shutdown() abort
    return ale#lsp#CreateMessage('shutdown')
endfunction

function! ale#lsp#message#Exit() abort
    return ale#lsp#CreateMessage('exit')
endfunction

function! ale#lsp#message#DidOpen(uri, languageId, version, text) abort
    return ale#lsp#CreateMessage('textDocument/didOpen', {
    \   'textDocument': {
    \       'uri': a:uri,
    \       'languageId': a:languageId,
    \       'version': a:version,
    \       'text': a:text,
    \   },
    \})
endfunction

function! ale#lsp#message#DidChange(uri, version, text) abort
    " For changes, we simply send the full text of the document to the server.
    return ale#lsp#CreateMessage('textDocument/didChange', {
    \   'textDocument': {
    \       'uri': a:uri,
    \       'version': a:version,
    \   },
    \   'contentChanges': [{'text': a:text}]
    \})
endfunction

function! ale#lsp#message#DidSave(uri) abort
    return ale#lsp#CreateMessage('textDocument/didSave', {
    \   'textDocument': {
    \       'uri': a:uri,
    \   },
    \})
endfunction

function! ale#lsp#message#DidClose(uri) abort
    return ale#lsp#CreateMessage('textDocument/didClose', {
    \   'textDocument': {
    \       'uri': a:uri,
    \   },
    \})
endfunction
