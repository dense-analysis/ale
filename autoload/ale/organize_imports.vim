function! ale#organize_imports#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') isnot# 'organizeImports'
        return
    endif

    if get(a:response, 'success', v:false) isnot v:true
        return
    endif

    echom 'organize imports response:' . string(a:response)
    let l:file_code_edits =  a:response.body

    call ale#code_action#HandleCodeAction({
    \   'description': 'Organize Imports',
    \   'changes': l:file_code_edits,
    \})
endfunction

function! s:OnReady(linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if a:linter.lsp isnot# 'tsserver'
        call ale#util#Execute('echom ''OrganizeImports currently only works with tsserver''')
    endif

    let l:buffer = a:lsp_details.buffer

    let l:Callback = function('ale#organize_imports#HandleTSServerResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    let l:message = ale#lsp#tsserver_message#OrganizeImports(l:buffer)

    let l:request_id = ale#lsp#Send(l:id, l:message)
endfunction

function! s:OrganizeImports(linter) abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getpos('.')[1:2]

    if a:linter.lsp isnot# 'tsserver'
        let l:column = min([l:column, len(getline(l:line))])
    endif

    let l:Callback = function('s:OnReady')
    call ale#lsp_linter#StartLSP(l:buffer, a:linter, l:Callback)
endfunction

function! ale#organize_imports#Execute() abort
    let l:lsp_linters = []

    for l:linter in ale#linter#Get(&filetype)
        if !empty(l:linter.lsp)
            call add(l:lsp_linters, l:linter)
        endif
    endfor

    if !empty(l:lsp_linters)
        for l:lsp_linter in l:lsp_linters
            call s:OrganizeImports(l:lsp_linter)
        endfor
    endif

endfunction
