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

function! ale#completion#FilterSuggestionsByPrefix(suggestions, prefix) abort
    " For completing...
    "   foo.
    "       ^
    " We need to include all of the given suggestions.
    if a:prefix ==# '.'
        return a:suggestions
    endif

    let l:filtered_suggestions = []

    " Filter suggestions down to those starting with the prefix we used for
    " finding suggestions in the first place.
    "
    " Some completion tools will
    " include suggestions which don't even start with the characters we have
    " already typed.
    for l:suggestion in a:suggestions
        " Add suggestions if the suggestion starts with a case-insensitive
        " match for the prefix.
        if l:suggestion.word[: len(a:prefix) - 1] ==? a:prefix
            call add(l:filtered_suggestions, l:suggestion)
        endif
    endfor

    return l:filtered_suggestions
endfunction

function! ale#completion#OmniFunc(findstart, base) abort
    if a:findstart
        let l:line = b:ale_completion_info.line
        let l:column = b:ale_completion_info.column
        let l:regex = s:GetRegex(s:omni_start_map, &filetype)
        let l:up_to_column = getline(l:line)[: l:column - 2]
        let l:match = matchstr(l:up_to_column, l:regex)

        return l:column - len(l:match) - 1
    else
        " Parse a new response if there is one.
        if exists('b:ale_completion_response')
        \&& exists('b:ale_completion_parser')
            let l:response = b:ale_completion_response
            let l:parser = b:ale_completion_parser

            unlet b:ale_completion_response
            unlet b:ale_completion_parser

            let l:prefix = b:ale_completion_info.prefix

            let b:ale_completion_result = ale#completion#FilterSuggestionsByPrefix(
            \   function(l:parser)(l:response),
            \   l:prefix
            \)[: g:ale_completion_max_suggestions]
        endif

        return get(b:, 'ale_completion_result', [])
    endif
endfunction

function! ale#completion#Show(response, completion_parser) abort
    " Remember the old omnifunc value, if there is one.
    " If we don't store an old one, we'll just never reset the option.
    " This will stop some random exceptions from appearing.
    if !exists('b:ale_old_omnifunc') && !empty(&l:omnifunc)
        let b:ale_old_omnifunc = &l:omnifunc
    endif

    " Set the list in the buffer, temporarily replace omnifunc with our
    " function, and then start omni-completion.
    let b:ale_completion_response = a:response
    let b:ale_completion_parser = a:completion_parser
    let &l:omnifunc = 'ale#completion#OmniFunc'
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

    for l:suggestion in a:response.body
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
        \   'icase': 1,
        \   'menu': join(l:displayParts, ''),
        \   'info': join(l:documentationParts, ''),
        \})
    endfor

    return l:results
endfunction

function! s:HandleTSServerLSPResponse(conn_id, response) abort
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

function! s:GetLSPCompletions(linter) abort
    let l:buffer = bufnr('')
    let l:lsp_details = ale#linter#StartLSP(
    \   l:buffer,
    \   a:linter,
    \   function('s:HandleTSServerLSPResponse'),
    \)

    if empty(l:lsp_details)
        return 0
    endif

    let l:id = l:lsp_details.connection_id
    let l:command = l:lsp_details.command
    let l:root = l:lsp_details.project_root

    let l:message = ale#lsp#tsserver_message#Completions(
    \   l:buffer,
    \   b:ale_completion_info.line,
    \   b:ale_completion_info.column,
    \   b:ale_completion_info.prefix,
    \)
    let l:request_id = ale#lsp#Send(l:id, l:message, l:root)

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
            call s:GetLSPCompletions(l:linter)
        endif
    endfor
endfunction

function! s:TimerHandler(...) abort
    let s:timer_id = -1

    call ale#completion#GetCompletions()
endfunction

function! ale#completion#Queue() abort
    let s:timer_pos = getcurpos()[1:2]

    " If we changed the text again while we're still waiting for a response,
    " then invalidate the requests before the timer ticks again.
    if exists('b:ale_completion_info')
        let b:ale_completion_info.request_id = 0
    endif

    if s:timer_id != -1
        call timer_stop(s:timer_id)
    endif

    let s:timer_id = timer_start(g:ale_completion_delay, function('s:TimerHandler'))
endfunction

function! ale#completion#Done() abort
    silent! pclose

    " Reset settings when completion is done.
    if exists('b:ale_old_omnifunc')
        let &l:omnifunc = b:ale_old_omnifunc
        unlet b:ale_old_omnifunc
    endif
endfunction

function! s:Setup(enabled) abort
    augroup ALECompletionGroup
        autocmd!

        if a:enabled
            autocmd TextChangedI * call ale#completion#Queue()
            autocmd CompleteDone * call ale#completion#Done()
        endif
    augroup END

    if !a:enabled
        augroup! ALECompletionGroup
    endif
endfunction

function! ale#completion#Enable() abort
    let g:ale_completion_enabled = 1
    call s:Setup(1)
endfunction

function! ale#completion#Disable() abort
    let g:ale_completion_enabled = 0
    call s:Setup(0)
endfunction
