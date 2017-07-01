" Author: w0rp <devw0rp@gmail.com>
" Description: Completion support for LSP linters

let s:timer = -1
let s:delay = 300
let s:max_suggestions = 20
let s:buffer_completion_map = {}

function! s:RememberCompletionInfo(buffer, executable, request_id, line, column) abort
    let s:buffer_completion_map[a:buffer] = {
    \   'executable': a:executable,
    \   'request_id': a:request_id,
    \   'line': a:line,
    \   'column': a:column,
    \}
endfunction

" Find completion information for a response, and delete the information
" if the request failed.
function! s:FindCompletionInfo(response) abort
    let l:matched_buffer = -1
    let l:matched_data = {}

    for l:key in keys(s:buffer_completion_map)
        let l:obj = s:buffer_completion_map[l:key]

        if l:obj.request_id ==# a:response.request_seq
            if get(a:response, 'success')
                let l:matched_buffer = str2nr(l:key)
                let l:matched_data = l:obj
            else
                " Clean up the data we remembered if the request failed.
                call remove(s:buffer_completion_map, l:matched_buffer)
            endif
        endif
    endfor

    return [l:matched_buffer, l:matched_data]
endfunction

function! s:HandleCompletions(response) abort
    let [l:buffer, l:info] = s:FindCompletionInfo(a:response)

    if l:buffer >= 0
        let l:names = []

        for l:suggestion in a:response.body[: s:max_suggestions]
            call add(l:names, l:suggestion.name)
        endfor

        let l:request_id = ale#lsp#SendMessageToProgram(
        \   l:info.executable,
        \   ale#lsp#tsserver_message#CompletionEntryDetails(
        \       l:buffer,
        \       l:info.line,
        \       l:info.column,
        \       l:names,
        \   ),
        \)

        if l:request_id
            let l:info.request_id = l:request_id
        else
            " Remove the info now if we failed to start the request.
            call remove(s:buffer_completion_map, l:buffer)
        endif
    endif
endfunction

function! s:HandleCompletionDetails(response) abort
    let [l:buffer, l:info] = s:FindCompletionInfo(a:response)

    if l:buffer >= 0
        call remove(s:buffer_completion_map, l:buffer)

        let l:name_list = []

        for l:suggestion in a:response.body[: s:max_suggestions]
            " Each suggestion has 'kind' and 'kindModifier' properties
            " which could be useful.
            " Each one of these parts has 'kind' properties
            let l:displayParts = []

            for l:part in l:suggestion.displayParts
                call add(l:displayParts, l:part.text)
            endfor

            " Each one of these parts has 'kind' properties
            let l:documentationParts = []

            for l:part in l:suggestion.documentation
                call add(l:documentationParts, l:part.text)
            endfor

            let l:text = l:suggestion.name
            \   . ' - '
            \   . join(l:displayParts, '')
            \   . (!empty(l:documentationParts) ? ' ' : '')
            \   . join(l:documentationParts, '')

            call add(l:name_list, l:text)
        endfor

        echom string(l:name_list)
    endif
endfunction

function! s:HandleLSPResponse(response) abort
    let l:command = get(a:response, 'command', '')

    if l:command ==# 'completions'
        call s:HandleCompletions(a:response)
    elseif l:command ==# 'completionEntryDetails'
        call s:HandleCompletionDetails(a:response)
    endif
endfunction

function! s:GetCompletionsForTSServer(buffer, linter, line, column) abort
    let l:executable = has_key(a:linter, 'executable_callback')
    \   ? ale#util#GetFunction(a:linter.executable_callback)(a:buffer)
    \   : a:linter.executable
    let l:command = l:executable

    let l:job_id = ale#lsp#StartProgram(
    \   l:executable,
    \   l:executable,
    \   function('s:HandleLSPResponse')
    \)

    if !l:job_id
        if g:ale_history_enabled
            call ale#history#Add(a:buffer, 'failed', l:job_id, l:command)
        endif
    endif

    if ale#lsp#OpenTSServerDocumentIfNeeded(l:executable, a:buffer)
        if g:ale_history_enabled
            call ale#history#Add(a:buffer, 'started', l:job_id, l:command)
        endif
    endif

    call ale#lsp#SendMessageToProgram(
    \   l:executable,
    \   ale#lsp#tsserver_message#Change(a:buffer),
    \)

    let l:request_id = ale#lsp#SendMessageToProgram(
    \   l:executable,
    \   ale#lsp#tsserver_message#Completions(a:buffer, a:line, a:column),
    \)

    if l:request_id
        call s:RememberCompletionInfo(
        \   a:buffer,
        \   l:executable,
        \   l:request_id,
        \   a:line,
        \   a:column,
        \)
    endif
endfunction

function! ale#completion#GetCompletions() abort
    let l:buffer = bufnr('')
    let [l:line, l:column] = getcurpos()[1:2]

    for l:linter in ale#linter#Get(getbufvar(l:buffer, '&filetype'))
        if l:linter.lsp ==# 'tsserver'
            call s:GetCompletionsForTSServer(l:buffer, l:linter, l:line, l:column)
        endif
    endfor
endfunction

function! s:TimerHandler(...) abort
    call ale#completion#GetCompletions()
endfunction

function! ale#completion#Queue() abort
    if s:timer != -1
        call timer_stop(s:timer)
        let s:timer = -1
    endif

    let s:timer = timer_start(s:delay, function('s:TimerHandler'))
endfunction

function! ale#completion#Start() abort
    augroup ALECompletionGroup
        autocmd!
        autocmd TextChangedI * call ale#completion#Queue()
    augroup END
endfunction
