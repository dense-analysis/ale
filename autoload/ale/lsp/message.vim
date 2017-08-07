" Author: w0rp <devw0rp@gmail.com>
" Description: Language Server Protocol message implementations
"
" Messages in this movie will be returned in the format
" [is_notification, method_name, params?]
let g:ale_lsp_next_version_id = 1

" The LSP protocols demands that we send every change to a document, including
" undo, with incrementing version numbers, so we'll just use one incrementing
" ID for everything.
function! ale#lsp#message#GetNextVersionID() abort
    " Use the current ID
    let l:id = g:ale_lsp_next_version_id

    " Increment the ID variable.
    let g:ale_lsp_next_version_id += 1

    " When the ID overflows, reset it to 1. By the time we hit the initial ID
    " again, the messages will be long gone.
    if g:ale_lsp_next_version_id < 1
        let g:ale_lsp_next_version_id = 1
    endif

    return l:id
endfunction

function! ale#lsp#message#Initialize(root_path) abort
    " TODO: Define needed capabilities.
    return [0, 'initialize', {
    \   'processId': getpid(),
    \   'rootPath': a:root_path,
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

function! ale#lsp#message#DidOpen(buffer, language_id) abort
    let l:lines = getbufline(a:buffer, 1, '$')

    return [1, 'textDocument/didOpen', {
    \   'textDocument': {
    \       'uri': ale#path#ToURI(expand('#' . a:buffer . ':p')),
    \       'languageId': a:language_id,
    \       'version': ale#lsp#message#GetNextVersionID(),
    \       'text': join(l:lines, "\n"),
    \   },
    \}]
endfunction

function! ale#lsp#message#DidChange(buffer) abort
    let l:lines = getbufline(a:buffer, 1, '$')

    " For changes, we simply send the full text of the document to the server.
    return [1, 'textDocument/didChange', {
    \   'textDocument': {
    \       'uri': ale#path#ToURI(expand('#' . a:buffer . ':p')),
    \       'version': ale#lsp#message#GetNextVersionID(),
    \   },
    \   'contentChanges': [{'text': join(l:lines, "\n")}]
    \}]
endfunction

function! ale#lsp#message#DidSave(buffer) abort
    return [1, 'textDocument/didSave', {
    \   'textDocument': {
    \       'uri': ale#path#ToURI(expand('#' . a:buffer . ':p')),
    \   },
    \}]
endfunction

function! ale#lsp#message#DidClose(buffer) abort
    return [1, 'textDocument/didClose', {
    \   'textDocument': {
    \       'uri': ale#path#ToURI(expand('#' . a:buffer . ':p')),
    \   },
    \}]
endfunction
