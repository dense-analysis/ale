let s:code_lens_map = {}

" Used to get the code lens map in tests.
function! ale#code_lens#GetMap() abort
    return deepcopy(s:code_lens_map)
endfunction

" Used to set the code lens map in tests.
function! ale#code_lens#SetMap(map) abort
    let s:code_lens_map = a:map
endfunction

function! ale#code_lens#ClearLSPData() abort
    let s:code_lens_map = {}
endfunction

" TODO: maybe check with exists instead?
let s:supported = exists('*nvim_buf_set_virtual_text')

let g:ale_code_lens_enabled = 0

function! ale#code_lens#Toggle() abort
    if g:ale_code_lens_enabled
        call ale#code_lens#Disable()
    else
        call ale#code_lens#Enable()
    endif
endfunction

function! ale#code_lens#Enable() abort
    let g:ale_code_lens_enabled = 1
    " We try to request code lens for the current buffer.
    call ale#code_lens#Request(bufnr('%'))
endfunction

function! ale#code_lens#Disable() abort
    let g:ale_code_lens_enabled = 0
    call ale#code_lens#Clear(bufnr('%'))
endfunction

function! ale#code_lens#ToggleBuffer(buffer) abort
    " Get the new value for the code_lens.
    let l:enabled = !getbufvar(a:buffer, 'ale_code_lens_enabled', 1)

    call setbufvar(a:buffer, 'ale_code_lens_enabled', l:enabled)

    if l:enabled
        call ale#code_lens#Request(a:buffer)
    else
        call ale#code_lens#Clear(a:buffer)
    endif
endfunction

function! ale#code_lens#EnableBuffer(buffer) abort
    " ALE is enabled by default for all buffers.
    if !getbufvar(a:buffer, 'ale_code_lens_enabled', 1)
        call ale#code_lens#ToggleBuffer(a:buffer)
    endif
endfunction

function! ale#code_lens#DisableBuffer(buffer) abort
    if getbufvar(a:buffer, 'ale_code_lens_enabled', 1)
        call ale#code_lens#ToggleBuffer(a:buffer)
    endif
endfunction

function! ale#code_lens#IsEnabled(buffer) abort
    return s:supported
         \ && g:ale_code_lens_enabled
         \ && getbufvar(a:buffer, 'ale_code_lens_enabled', 1)
endfunction

function! s:GetNamespace(buffer) abort
    if getbufvar(a:buffer, 'ale_code_lens_ns', -1) == -1
        " NOTE: This will highlights nothing but will allocate new id
        call setbufvar(
        \ a:buffer,
        \ 'ale_code_lens_ns',
        \ nvim_buf_add_highlight(a:buffer, 0, '', 0, 0, -1)
        \)
    endif

    return getbufvar(a:buffer, 'ale_code_lens_ns')
endfunction

function! ale#code_lens#Show(buffer, items) abort
    let l:namespace = s:GetNamespace(a:buffer)
    for item in a:items
        let text = '  ' . substitute(l:item.title, '\n', ' ', 'g')
        call nvim_buf_set_virtual_text(
        \ a:buffer, l:namespace,
        \ item.line, [[text, 'Comment']], {}
        \)
    endfor
endfunction

function! ale#code_lens#Clear(buffer) abort
    let l:namespace = s:GetNamespace(a:buffer)
    call nvim_buf_clear_namespace(a:buffer, l:namespace, 0, -1)
endfunction

function! ale#code_lens#HandleLSPResponse(conn_id, response) abort
    if has_key(a:response, 'id')
    \&& has_key(s:code_lens_map, a:response.id)
        let l:options = remove(s:code_lens_map, a:response.id)

        let l:result = get(a:response, 'result', v:null)
        let l:item_list = []

        if type(l:result) is v:t_list
            " Each item looks like this:
            "{
            "  'range': {
            "    'start': { 'line': 7, 'character': 2 },
            "    'end': { 'line': 7, 'character': 12 }
            "  },
            "  'command': { 'title': 'int', 'command': '' }
            "}
            for l:response_item in l:result
                call add(l:item_list, {
                \ 'line': l:response_item.range.start.line,
                \ 'title': l:response_item.command.title,
                \})
            endfor
        endif

        if !empty(l:item_list)
            call ale#code_lens#Show(l:options.buffer, l:item_list)
        else
        endif
    endif
endfunction

function! s:OnReady(linter, lsp_details, ...) abort
    let l:buffer = a:lsp_details.buffer

    " If we already made a request, stop here.
    if getbufvar(l:buffer, 'ale_code_lens_request_made', 0)
        return
    endif

    let l:id = a:lsp_details.connection_id

    let l:Callback = function('ale#code_lens#HandleLSPResponse')
    call ale#lsp#RegisterCallback(l:id, l:Callback)

    let l:message = ale#lsp#message#CodeLens(l:buffer)
    let l:request_id = ale#lsp#Send(l:id, l:message)

    call setbufvar(l:buffer, 'ale_code_lens_request_made', 1)
    let s:code_lens_map[l:request_id] = {
    \   'buffer': l:buffer,
    \}
endfunction

function! s:Request(linter, buffer) abort
    let l:lsp_details = ale#lsp_linter#StartLSP(a:buffer, a:linter)

    if !empty(l:lsp_details)
        call ale#lsp#WaitForCapability(
        \   l:lsp_details.connection_id,
        \   'code_lens',
        \   function('s:OnReady', [a:linter, l:lsp_details]),
        \)
    endif
endfunction

function! ale#code_lens#Request(buffer) abort
    if !ale#code_lens#IsEnabled(a:buffer)
        return
    endif

    " Set a flag so we only make one request.
    call setbufvar(a:buffer, 'ale_code_lens_request_made', 0)

    for l:linter in ale#linter#Get(getbufvar(a:buffer, '&filetype'))
        if !empty(l:linter.lsp) && l:linter.lsp isnot# 'tsserver'
            call s:Request(l:linter, a:buffer)
        endif
    endfor
endfunction
