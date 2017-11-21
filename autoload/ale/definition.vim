" Author: w0rp <devw0rp@gmail.com>
" Description: Go to definition support for LSP linters.

let s:go_to_definition_map = {}

" Used to get the definition map in tests.
function! ale#definition#GetMap() abort
    return deepcopy(s:go_to_definition_map)
endfunction

" Used to set the definition map in tests.
function! ale#definition#SetMap(map) abort
    let s:go_to_definition_map = a:map
endfunction

" This function is used so we can check the execution of commands without
" running them.
function! ale#definition#Execute(expr) abort
    execute a:expr
endfunction

function! ale#definition#Open(options, filename, line, column) abort
    if a:options.open_in_tab
        call ale#definition#Execute('tabedit ' . fnameescape(a:filename))
    else
        call ale#definition#Execute('edit ' . fnameescape(a:filename))
    endif

    call cursor(a:line, a:column)
endfunction

function! ale#definition#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') is# 'definition'
    \&& has_key(s:go_to_definition_map, a:response.request_seq)
        let l:options = remove(s:go_to_definition_map, a:response.request_seq)

        if get(a:response, 'success', v:false) is v:true
            let l:filename = a:response.body[0].file
            let l:line = a:response.body[0].start.line
            let l:column = a:response.body[0].start.offset

            call ale#definition#Open(l:options, l:filename, l:line, l:column)
        endif
    endif
endfunction

function! s:GoToLSPDefinition(linter, options) abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getcurpos()[1:2]

    let l:lsp_details = ale#linter#StartLSP(
    \   l:buffer,
    \   a:linter,
    \   function('ale#definition#HandleTSServerResponse'),
    \)

    if empty(l:lsp_details)
        return 0
    endif

    let l:id = l:lsp_details.connection_id
    let l:root = l:lsp_details.project_root

    let l:message = ale#lsp#tsserver_message#Definition(
    \   l:buffer,
    \   l:line,
    \   l:column
    \)
    let l:request_id = ale#lsp#Send(l:id, l:message, l:root)

    let s:go_to_definition_map[l:request_id] = {
    \   'open_in_tab': get(a:options, 'open_in_tab', 0),
    \}
endfunction

function! ale#definition#GoTo(options) abort
    for l:linter in ale#linter#Get(&filetype)
        if l:linter.lsp is# 'tsserver'
            call s:GoToLSPDefinition(l:linter, a:options)
        endif
    endfor
endfunction
