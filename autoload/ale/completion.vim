" Author: w0rp <devw0rp@gmail.com>
" Description: Completion support for LSP linters

let s:timer_id = -1

function! s:GetRegex(map, filetype) abort
    for l:part in reverse(split(a:filetype, '\.'))
        let l:regex = get(a:map, l:part, [])

        if !empty(l:regex)
            return l:regex
        endif
    endfor

    return ''
endfunction

" Regular expressions for checking the characters in the line before where
" the insert cursor is. If one of these matches, we'll check for completions.
let s:should_complete_map = {
\   'javascript': '\v[a-zA-Z$_][a-zA-Z$_0-9]*$|\.$',
\   'typescript': '\v[a-zA-Z$_][a-zA-Z$_0-9]*$|\.$',
\}

" Check if we should look for completions for a language.
function! ale#completion#GetPrefix(filetype, line, column) abort
    let l:regex = s:GetRegex(s:should_complete_map, a:filetype)
    " The column we're using completions for is where we are inserting text,
    " like so:
    "   abc
    "      ^
    " So we need check the text in the column before that position.
    return matchstr(getline(a:line)[: a:column - 2], l:regex)
endfunction

" Regular expressions for finding the start column to replace with completion.
let s:omni_start_map = {
\   'javascript': '\v[a-zA-Z$_][a-zA-Z$_0-9]*$',
\   'typescript': '\v[a-zA-Z$_][a-zA-Z$_0-9]*$',
\}

function! ale#completion#OmniFunc(findstart, base) abort
    if a:findstart
        let l:line = b:ale_completion_info.line
        let l:column = b:ale_completion_info.column
        let l:regex = s:GetRegex(s:omni_start_map, &filetype)
        let l:up_to_column = getline(l:line)[: l:column - 1]
        let l:match = matchstr(l:up_to_column, l:regex)

        return l:column - len(l:match) - 1
    else
        " Reset the settings now
        let &omnifunc = b:ale_old_omnifunc
        let &completeopt = b:ale_old_completeopt
        let l:response = b:ale_completion_response
        let l:parser = b:ale_completion_parser

        unlet b:ale_completion_response
        unlet b:ale_completion_parser
        unlet b:ale_old_omnifunc
        unlet b:ale_old_completeopt

        return function(l:parser)(l:response)
    endif
endfunction

function! ale#completion#Show(response, completion_parser) abort
    " Remember the old omnifunc value.
    if !exists('b:ale_old_omnifunc')
        let b:ale_old_omnifunc = &omnifunc
        let b:ale_old_completeopt = &completeopt
    endif

    " Set the list in the buffer, temporarily replace omnifunc with our
    " function, and then start omni-completion.
    let b:ale_completion_response = a:response
    let b:ale_completion_parser = a:completion_parser
    let &omnifunc = 'ale#completion#OmniFunc'
    let &completeopt = 'menu,noinsert,noselect'
    call feedkeys("\<C-x>\<C-o>", 'n')
endfunction

function! s:CompletionStillValid(request_id) abort
    let [l:line, l:column] = getcurpos()[1:2]

    return has_key(b:, 'ale_completion_info')
    \&& b:ale_completion_info.request_id == a:request_id
    \&& b:ale_completion_info.line == l:line
    \&& b:ale_completion_info.column == l:column
endfunction

function! ale#completion#ParseTSServerCompletions(response) abort
    let l:names = []

    for l:suggestion in a:response.body[: g:ale_completion_max_suggestions]
        call add(l:names, l:suggestion.name)
    endfor

    return l:names
endfunction

function! ale#completion#ParseTSServerCompletionEntryDetails(response) abort
    let l:results = []

    for l:suggestion in a:response.body
        let l:displayParts = []

        for l:part in l:suggestion.displayParts
            call add(l:displayParts, l:part.text)
        endfor

        " Each one of these parts has 'kind' properties
        let l:documentationParts = []

        for l:part in get(l:suggestion, 'documentation', [])
            call add(l:documentationParts, l:part.text)
        endfor

        if l:suggestion.kind ==# 'clasName'
            let l:kind = 'f'
        elseif l:suggestion.kind ==# 'parameterName'
            let l:kind = 'f'
        else
            let l:kind = 'v'
        endif

        " See :help complete-items
        call add(l:results, {
        \   'word': l:suggestion.name,
        \   'kind': l:kind,
        \   'menu': join(l:displayParts, ''),
        \   'info': join(l:documentationParts, ''),
        \})
    endfor

    return l:results
endfunction

function! s:HandleTSServerLSPResponse(response) abort
    if !s:CompletionStillValid(get(a:response, 'request_seq'))
        return
    endif

    if !has_key(a:response, 'body')
        return
    endif

    let l:command = get(a:response, 'command', '')

    if l:command ==# 'completions'
        let l:names = ale#completion#ParseTSServerCompletions(a:response)

        if !empty(l:names)
            let b:ale_completion_info.request_id = ale#lsp#Send(
            \   b:ale_completion_info.conn_id,
            \   ale#lsp#tsserver_message#CompletionEntryDetails(
            \       bufnr(''),
            \       b:ale_completion_info.line,
            \       b:ale_completion_info.column,
            \       l:names,
            \   ),
            \)
        endif
    elseif l:command ==# 'completionEntryDetails'
        call ale#completion#Show(
        \   a:response,
        \   'ale#completion#ParseTSServerCompletionEntryDetails',
        \)
    endif
endfunction

function! s:GetCompletionsForTSServer(linter) abort
    let l:buffer = bufnr('')
    let l:executable = ale#linter#GetExecutable(l:buffer, a:linter)
    let l:command = ale#job#PrepareCommand(
    \ ale#linter#GetCommand(l:buffer, a:linter),
    \)
    let l:id = ale#lsp#StartProgram(
    \   l:executable,
    \   l:command,
    \   function('s:HandleTSServerLSPResponse'),
    \)

    if !l:id
        if g:ale_history_enabled
            call ale#history#Add(l:buffer, 'failed', l:id, l:command)
        endif
    endif

    if ale#lsp#OpenTSServerDocumentIfNeeded(l:id, l:buffer)
        if g:ale_history_enabled
            call ale#history#Add(l:buffer, 'started', l:id, l:command)
        endif
    endif

    call ale#lsp#Send(l:id, ale#lsp#tsserver_message#Change(l:buffer))

    let l:request_id = ale#lsp#Send(
    \   l:id,
    \   ale#lsp#tsserver_message#Completions(
    \       l:buffer,
    \       b:ale_completion_info.line,
    \       b:ale_completion_info.column,
    \       b:ale_completion_info.prefix,
    \   ),
    \)

    if l:request_id
        let b:ale_completion_info.conn_id = l:id
        let b:ale_completion_info.request_id = l:request_id
    endif
endfunction

function! ale#completion#GetCompletions() abort
    let [l:line, l:column] = getcurpos()[1:2]

    if s:timer_pos != [l:line, l:column]
        return
    endif

    let l:prefix = ale#completion#GetPrefix(&filetype, l:line, l:column)

    if empty(l:prefix)
        return
    endif

    let b:ale_completion_info = {
    \   'line': l:line,
    \   'column': l:column,
    \   'prefix': l:prefix,
    \   'conn_id': 0,
    \   'request_id': 0,
    \}

    for l:linter in ale#linter#Get(&filetype)
        if l:linter.lsp ==# 'tsserver'
            call s:GetCompletionsForTSServer(l:linter)
        endif
    endfor
endfunction

function! s:TimerHandler(...) abort
    let s:timer_id = -1

    call ale#completion#GetCompletions()
endfunction

function! ale#completion#Queue() abort
    let s:timer_pos = getcurpos()[1:2]

    if s:timer_id != -1
        call timer_stop(s:timer_id)
    endif

    let s:timer_id = timer_start(g:ale_completion_delay, function('s:TimerHandler'))
endfunction

function! s:Setup(enabled) abort
    augroup ALECompletionGroup
        autocmd!

        if a:enabled
            autocmd TextChangedI * call ale#completion#Queue()
            autocmd CompleteDone * silent! pclose
        endif
    augroup END

    if !a:enabled
        augroup! ALECompletionGroup
    endif
endfunction

function! ale#completion#Enable() abort
    call s:Setup(1)
endfunction

function! ale#completion#Disable() abort
    call s:Setup(0)
endfunction
