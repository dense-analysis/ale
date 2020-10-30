" Author: Dalius Dobravolskas <dalius.dobravolskas@gmail.com>
" Description: Code Fix support for tsserver

function! s:message(message) abort
    call ale#util#Execute('echom ' . string(a:message))
endfunction

function! ale#codefix#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') isnot# 'getCodeFixes'
        return
    endif

    if get(a:response, 'success', v:false) is v:false
        let l:message = get(a:response, 'message', 'unknown')
        call s:message('Error while getting code fixes. Reason: ' . l:message)

        return
    endif

    if len(a:response.body) == 0
        call s:message('No code fixes available.')

        return
    endif

    let l:code_fix_to_apply = 0

    if len(a:response.body) == 1
        let l:code_fix_to_apply = 1
    else
        let l:codefix_no = 1
        let l:codefixstring = "Code Fixes:\n"

        for l:codefix in a:response.body
            let l:codefixstring .= l:codefix_no . ') ' . l:codefix.description . "\n"
            let l:codefix_no += 1
        endfor

        let l:codefixstring .= 'Type number and <Enter> (empty cancels): '

        let l:code_fix_to_apply = ale#util#Input(l:codefixstring, '')
        let l:code_fix_to_apply = str2nr(l:code_fix_to_apply)

        if l:code_fix_to_apply == 0
            return
        endif
    endif

    let l:changes = a:response.body[l:code_fix_to_apply - 1].changes

    call ale#code_action#HandleCodeAction({
    \ 'description': 'codefix',
    \ 'changes': l:changes,
    \}, {})
endfunction

function! s:OnReady(line, column, linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if a:linter.lsp isnot# 'tsserver'
        call s:message('CodeFix currently only works with tsserver')

        return
    endif

    if !ale#lsp#HasCapability(l:id, 'code_actions')
        return
    endif

    let l:buffer = a:lsp_details.buffer

    if !has_key(g:ale_buffer_info, l:buffer)
        return
    endif

    let l:nearest_error = v:null
    let l:nearest_error_diff = -1

    for l:error in get(g:ale_buffer_info[l:buffer], 'loclist', [])
        if l:error.lnum == a:line
            let l:diff = abs(l:error.col - a:column)

            if l:nearest_error_diff == -1 || l:diff < l:nearest_error_diff
                let l:nearest_error_diff = l:diff
                let l:nearest_error = l:error.code
            endif
        endif
    endfor

    let l:Callback = function('ale#codefix#HandleTSServerResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#GetCodeFixes(
        \   l:buffer,
        \   a:line,
        \   a:column,
        \   a:line,
        \   a:column,
        \   [l:nearest_error],
        \)
    endif

    let l:request_id = ale#lsp#Send(l:id, l:message)
endfunction

function! s:ExecuteGetCodeFix(linter) abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getpos('.')[1:2]

    if a:linter.lsp isnot# 'tsserver'
        let l:column = min([l:column, len(getline(l:line))])
    endif

    let l:Callback = function(
    \ 's:OnReady', [l:line, l:column])
    call ale#lsp_linter#StartLSP(l:buffer, a:linter, l:Callback)
endfunction

function! ale#codefix#Execute() abort
    let l:lsp_linters = []

    for l:linter in ale#linter#Get(&filetype)
        if !empty(l:linter.lsp)
            call add(l:lsp_linters, l:linter)
        endif
    endfor

    if empty(l:lsp_linters)
        call s:message('No active LSPs')

        return
    endif

    for l:lsp_linter in l:lsp_linters
        call s:ExecuteGetCodeFix(l:lsp_linter)
    endfor
endfunction
