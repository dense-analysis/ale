" Author: w0rp <devw0rp@gmail.com>
" Description: Integration between linters and LSP/tsserver.

" This code isn't loaded if a user never users LSP features or linters.

" Associates LSP connection IDs with linter names.
if !has_key(s:, 'lsp_linter_map')
    let s:lsp_linter_map = {}
endif

" Check if diagnostics for a particular linter should be ignored.
function! s:ShouldIgnore(buffer, linter_name) abort
    let l:config = ale#Var(a:buffer, 'linters_ignore')

    " Don't load code for ignoring diagnostics if there's nothing to ignore.
    if empty(l:config)
        return 0
    endif

    let l:filetype = getbufvar(a:buffer, '&filetype')
    let l:ignore_list = ale#engine#ignore#GetList(l:filetype, l:config)

    return index(l:ignore_list, a:linter_name) >= 0
endfunction

function! s:HandleLSPDiagnostics(conn_id, response) abort
    let l:linter_name = s:lsp_linter_map[a:conn_id]
    let l:filename = ale#path#FromURI(a:response.params.uri)
    let l:buffer = bufnr(l:filename)

    if s:ShouldIgnore(l:buffer, l:linter_name)
        return
    endif

    if l:buffer <= 0
        return
    endif

    let l:loclist = ale#lsp#response#ReadDiagnostics(a:response)

    call ale#engine#HandleLoclist(l:linter_name, l:buffer, l:loclist, 0)
endfunction

function! s:HandleTSServerDiagnostics(response, error_type) abort
    let l:linter_name = 'tsserver'
    let l:buffer = bufnr(a:response.body.file)
    let l:info = get(g:ale_buffer_info, l:buffer, {})

    if empty(l:info)
        return
    endif

    if s:ShouldIgnore(l:buffer, l:linter_name)
        return
    endif

    let l:thislist = ale#lsp#response#ReadTSServerDiagnostics(a:response)
    let l:no_changes = 0

    " tsserver sends syntax and semantic errors in separate messages, so we
    " have to collect the messages separately for each buffer and join them
    " back together again.
    if a:error_type is# 'syntax'
        if len(l:thislist) is 0 && len(get(l:info, 'syntax_loclist', [])) is 0
            let l:no_changes = 1
        endif

        let l:info.syntax_loclist = l:thislist
    else
        if len(l:thislist) is 0 && len(get(l:info, 'semantic_loclist', [])) is 0
            let l:no_changes = 1
        endif

        let l:info.semantic_loclist = l:thislist
    endif

    if l:no_changes
        return
    endif

    let l:loclist = get(l:info, 'semantic_loclist', [])
    \   + get(l:info, 'syntax_loclist', [])

    call ale#engine#HandleLoclist(l:linter_name, l:buffer, l:loclist, 0)
endfunction

function! s:HandleLSPErrorMessage(linter_name, response) abort
    if !g:ale_history_enabled || !g:ale_history_log_output
        return
    endif

    if empty(a:linter_name)
        return
    endif

    let l:message = ale#lsp#response#GetErrorMessage(a:response)

    if empty(l:message)
        return
    endif

    " This global variable is set here so we don't load the debugging.vim file
    " until someone uses :ALEInfo.
    let g:ale_lsp_error_messages = get(g:, 'ale_lsp_error_messages', {})

    if !has_key(g:ale_lsp_error_messages, a:linter_name)
        let g:ale_lsp_error_messages[a:linter_name] = []
    endif

    call add(g:ale_lsp_error_messages[a:linter_name], l:message)
endfunction

function! ale#lsp_linter#HandleLSPResponse(conn_id, response) abort
    let l:method = get(a:response, 'method', '')

    if get(a:response, 'jsonrpc', '') is# '2.0' && has_key(a:response, 'error')
        let l:linter_name = get(s:lsp_linter_map, a:conn_id, '')

        call s:HandleLSPErrorMessage(l:linter_name, a:response)
    elseif l:method is# 'textDocument/publishDiagnostics'
        call s:HandleLSPDiagnostics(a:conn_id, a:response)
    elseif get(a:response, 'type', '') is# 'event'
    \&& get(a:response, 'event', '') is# 'semanticDiag'
        call s:HandleTSServerDiagnostics(a:response, 'semantic')
    elseif get(a:response, 'type', '') is# 'event'
    \&& get(a:response, 'event', '') is# 'syntaxDiag'
        call s:HandleTSServerDiagnostics(a:response, 'syntax')
    endif
endfunction

function! ale#lsp_linter#GetOptions(buffer, linter) abort
    if has_key(a:linter, 'initialization_options_callback')
        return ale#util#GetFunction(a:linter.initialization_options_callback)(a:buffer)
    endif

    if has_key(a:linter, 'initialization_options')
        let l:Options = a:linter.initialization_options

        if type(l:Options) is v:t_func
            let l:Options = l:Options(a:buffer)
        endif

        return l:Options
    endif

    return {}
endfunction

function! ale#lsp_linter#GetConfig(buffer, linter) abort
    if has_key(a:linter, 'lsp_config_callback')
        return ale#util#GetFunction(a:linter.lsp_config_callback)(a:buffer)
    endif

    if has_key(a:linter, 'lsp_config')
        let l:Config = a:linter.lsp_config

        if type(l:Config) is v:t_func
            let l:Config = l:Config(a:buffer)
        endif

        return l:Config
    endif

    return {}
endfunction

function! ale#lsp_linter#FindProjectRoot(buffer, linter) abort
    let l:buffer_ale_root = getbufvar(a:buffer, 'ale_lsp_root', {})

    if type(l:buffer_ale_root) is v:t_string
        return l:buffer_ale_root
    endif

    " Try to get a buffer-local setting for the root
    if has_key(l:buffer_ale_root, a:linter.name)
        let l:Root = l:buffer_ale_root[a:linter.name]

        if type(l:Root) is v:t_func
            return l:Root(a:buffer)
        else
            return l:Root
        endif
    endif

    " Try to get a global setting for the root
    if has_key(g:ale_lsp_root, a:linter.name)
        let l:Root = g:ale_lsp_root[a:linter.name]

        if type(l:Root) is v:t_func
            return l:Root(a:buffer)
        else
            return l:Root
        endif
    endif

    " Fall back to the linter-specific configuration
    if has_key(a:linter, 'project_root')
        let l:Root = a:linter.project_root

        return type(l:Root) is v:t_func ? l:Root(a:buffer) : l:Root
    endif

    return ale#util#GetFunction(a:linter.project_root_callback)(a:buffer)
endfunction

" This function is accessible so tests can call it.
function! ale#lsp_linter#OnInit(linter, details, Callback) abort
    let l:buffer = a:details.buffer
    let l:conn_id = a:details.connection_id
    let l:command = a:details.command

    let l:config = ale#lsp_linter#GetConfig(l:buffer, a:linter)
    let l:language_id = ale#util#GetFunction(a:linter.language_callback)(l:buffer)

    call ale#lsp#UpdateConfig(l:conn_id, l:buffer, l:config)

    if ale#lsp#OpenDocument(l:conn_id, l:buffer, l:language_id)
        if g:ale_history_enabled && !empty(l:command)
            call ale#history#Add(l:buffer, 'started', l:conn_id, l:command)
        endif
    endif

    " The change message needs to be sent for tsserver before doing anything.
    if a:linter.lsp is# 'tsserver'
        call ale#lsp#NotifyForChanges(l:conn_id, l:buffer)
    endif

    call a:Callback(a:linter, a:details)
endfunction

" Given a buffer, an LSP linter, start up an LSP linter and get ready to
" receive messages for the document.
function! ale#lsp_linter#StartLSP(buffer, linter, Callback) abort
    let l:command = ''
    let l:address = ''
    let l:root = ale#lsp_linter#FindProjectRoot(a:buffer, a:linter)

    if empty(l:root) && a:linter.lsp isnot# 'tsserver'
        " If there's no project root, then we can't check files with LSP,
        " unless we are using tsserver, which doesn't use project roots.
        return 0
    endif

    let l:init_options = ale#lsp_linter#GetOptions(a:buffer, a:linter)

    if a:linter.lsp is# 'socket'
        let l:address = ale#linter#GetAddress(a:buffer, a:linter)
        let l:conn_id = ale#lsp#Register(l:address, l:root, l:init_options)
        let l:ready = ale#lsp#ConnectToAddress(l:conn_id, l:address)
    else
        let l:executable = ale#linter#GetExecutable(a:buffer, a:linter)

        if !ale#engine#IsExecutable(a:buffer, l:executable)
            return 0
        endif

        let l:conn_id = ale#lsp#Register(l:executable, l:root, l:init_options)

        " tsserver behaves differently, so tell the LSP API that it is tsserver.
        if a:linter.lsp is# 'tsserver'
            call ale#lsp#MarkConnectionAsTsserver(l:conn_id)
        endif

        let l:command = ale#linter#GetCommand(a:buffer, a:linter)
        " Format the command, so %e can be formatted into it.
        let l:command = ale#command#FormatCommand(a:buffer, l:executable, l:command, 0, v:false)[1]
        let l:command = ale#job#PrepareCommand(a:buffer, l:command)
        let l:ready = ale#lsp#StartProgram(l:conn_id, l:executable, l:command)
    endif

    if !l:ready
        if g:ale_history_enabled && !empty(l:command)
            call ale#history#Add(a:buffer, 'failed', l:conn_id, l:command)
        endif

        return 0
    endif


    let l:details = {
    \   'buffer': a:buffer,
    \   'connection_id': l:conn_id,
    \   'command': l:command,
    \   'project_root': l:root,
    \}

    call ale#lsp#OnInit(l:conn_id, {->
    \   ale#lsp_linter#OnInit(a:linter, l:details, a:Callback)
    \})

    return 1
endfunction

function! s:CheckWithLSP(linter, details) abort
    let l:buffer = a:details.buffer
    let l:info = get(g:ale_buffer_info, l:buffer)

    if empty(l:info)
        return
    endif

    let l:id = a:details.connection_id

    " Register a callback now for handling errors now.
    let l:Callback = function('ale#lsp_linter#HandleLSPResponse')
    call ale#lsp#RegisterCallback(l:id, l:Callback)

    " Remember the linter this connection is for.
    let s:lsp_linter_map[l:id] = a:linter.name

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#Geterr(l:buffer)
        let l:notified = ale#lsp#Send(l:id, l:message) != 0
    else
        let l:notified = ale#lsp#NotifyForChanges(l:id, l:buffer)
    endif

    " If this was a file save event, also notify the server of that.
    if a:linter.lsp isnot# 'tsserver'
    \&& getbufvar(l:buffer, 'ale_save_event_fired', 0)
        let l:save_message = ale#lsp#message#DidSave(l:buffer)
        let l:notified = ale#lsp#Send(l:id, l:save_message) != 0
    endif

    if l:notified
        call ale#engine#MarkLinterActive(l:info, a:linter)
    endif
endfunction

function! ale#lsp_linter#CheckWithLSP(buffer, linter) abort
    return ale#lsp_linter#StartLSP(a:buffer, a:linter, function('s:CheckWithLSP'))
endfunction

" Clear LSP linter data for the linting engine.
function! ale#lsp_linter#ClearLSPData() abort
    let s:lsp_linter_map = {}
endfunction

" Just for tests.
function! ale#lsp_linter#SetLSPLinterMap(replacement_map) abort
    let s:lsp_linter_map = a:replacement_map
endfunction
