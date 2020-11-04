" Author: Dalius Dobravolskas <dalius.dobravolskas@gmail.com>
" Description: Code Fix support for tsserver

let s:codefix_map = {}

" Used to get the codefix map in tests.
function! ale#codefix#GetMap() abort
    return deepcopy(s:codefix_map)
endfunction

" Used to set the codefix map in tests.
function! ale#codefix#SetMap(map) abort
    let s:codefix_map = a:map
endfunction

function! ale#codefix#ClearLSPData() abort
    let s:codefix_map = {}
endfunction

function! s:message(message) abort
    call ale#util#Execute('echom ' . string(a:message))
endfunction

function! ale#codefix#HandleTSServerResponse(conn_id, response) abort
    if !has_key(a:response, 'request_seq')
    \ || !has_key(s:codefix_map, a:response.request_seq)
        return
    endif

    let l:location = remove(s:codefix_map, a:response.request_seq)

    if get(a:response, 'command', '') is'getCodeFixes'
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
    elseif get(a:response, 'command', '') is# 'getApplicableRefactors'
        if get(a:response, 'success', v:false) is v:false
            let l:message = get(a:response, 'message', 'unknown')
            call s:message('Error while getting applicable refactors. Reason: ' . l:message)

            return
        endif

        if len(a:response.body) == 0
            call s:message('No applicable refactors available.')

            return
        endif

        let l:refactors = []

        for l:item in a:response.body
            for l:action in l:item.actions
                call add(l:refactors, {
                \   'name': l:action.description,
                \   'id': [l:item.name, l:action.name],
                \})
            endfor
        endfor

        let l:refactor_no = 1
        let l:refactorstring = "Applicable refactors:\n"

        for l:refactor in l:refactors
            let l:refactorstring .= l:refactor_no . ') ' . l:refactor.name . "\n"
            let l:refactor_no += 1
        endfor

        let l:refactorstring .= 'Type number and <Enter> (empty cancels): '

        let l:refactor_to_apply = ale#util#Input(l:refactorstring, '')
        let l:refactor_to_apply = str2nr(l:refactor_to_apply)

        if l:refactor_to_apply == 0
            return
        endif

        let l:id = l:refactors[l:refactor_to_apply - 1].id

        let l:message = ale#lsp#tsserver_message#GetEditsForRefactor(
        \   l:location.buffer,
        \   l:location.line,
        \   l:location.column,
        \   l:location.end_line,
        \   l:location.end_column,
        \   l:id[0],
        \   l:id[1],
        \)

        let l:request_id = ale#lsp#Send(l:location.connection_id, l:message)

        let s:codefix_map[l:request_id] = l:location
    elseif get(a:response, 'command', '') is# 'getEditsForRefactor'
        if get(a:response, 'success', v:false) is v:false
            let l:message = get(a:response, 'message', 'unknown')
            call s:message('Error while getting edits for refactor. Reason: ' . l:message)

            return
        endif

        call ale#code_action#HandleCodeAction({
        \ 'description': 'editsForRefactor',
        \ 'changes': a:response.body.edits,
        \}, {})
    endif
endfunction

function! s:OnReady(line, column, end_line, end_column, linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if a:linter.lsp isnot# 'tsserver'
        call s:message('ALECodeAction currently only works with tsserver')

        return
    endif

    if !ale#lsp#HasCapability(l:id, 'code_actions')
        return
    endif

    let l:buffer = a:lsp_details.buffer

    if a:line == a:end_line && a:column == a:end_column
        if !has_key(g:ale_buffer_info, l:buffer)
            return
        endif

        let l:nearest_error = v:null
        let l:nearest_error_diff = -1

        for l:error in get(g:ale_buffer_info[l:buffer], 'loclist', [])
            if has_key(l:error, 'code') && l:error.lnum == a:line
                let l:diff = abs(l:error.col - a:column)

                if l:nearest_error_diff == -1 || l:diff < l:nearest_error_diff
                    let l:nearest_error_diff = l:diff
                    let l:nearest_error = l:error.code
                endif
            endif
        endfor

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
    else
        if a:linter.lsp is# 'tsserver'
            let l:message = ale#lsp#tsserver_message#GetApplicableRefactors(
            \   l:buffer,
            \   a:line,
            \   a:column,
            \   a:end_line,
            \   a:end_column,
            \)
        endif
    endif

    let l:Callback = function('ale#codefix#HandleTSServerResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    let l:request_id = ale#lsp#Send(l:id, l:message)

    let s:codefix_map[l:request_id] = {
    \ 'connection_id': l:id,
    \ 'buffer': l:buffer,
    \ 'line': a:line,
    \ 'column': a:column,
    \ 'end_line': a:end_line,
    \ 'end_column': a:end_column,
    \}
endfunction

function! s:ExecuteGetCodeFix(linter, range) abort
    let l:buffer = bufnr('')

    if a:range == 0
        let [l:line, l:column] = getpos('.')[1:2]
        let l:end_line = l:line
        let l:end_column = l:column
    else
        let [l:line, l:column] = getpos("'<")[1:2]
        let [l:end_line, l:end_column] = getpos("'>")[1:2]

        let l:column = min([l:column, len(getline(l:line))])
        let l:end_column = min([l:end_column, len(getline(l:end_line))])
    endif

    if a:linter.lsp isnot# 'tsserver'
        let l:column = min([l:column, len(getline(l:line))])
    endif

    let l:Callback = function(
    \ 's:OnReady', [l:line, l:column, l:end_line, l:end_column])
    call ale#lsp_linter#StartLSP(l:buffer, a:linter, l:Callback)
endfunction

function! ale#codefix#Execute(range) abort
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
        call s:ExecuteGetCodeFix(l:lsp_linter, a:range)
    endfor
endfunction
