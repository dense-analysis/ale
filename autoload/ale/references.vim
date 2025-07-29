let g:ale_default_navigation = get(g:, 'ale_default_navigation', 'buffer')
let g:ale_references_show_contents = get(g:, 'ale_references_show_contents', 1)
let g:ale_references_use_fzf = get(g:, 'ale_references_use_fzf', 0)

let s:references_map = {}

" Used to get the references map in tests.
function! ale#references#GetMap() abort
    return deepcopy(s:references_map)
endfunction

" Used to set the references map in tests.
function! ale#references#SetMap(map) abort
    let s:references_map = a:map
endfunction

function! ale#references#ClearLSPData() abort
    let s:references_map = {}
endfunction

function! ale#references#FormatTSResponseItem(response_item, options) abort
    let l:match = substitute(a:response_item.lineText, '^\s*\(.\{-}\)\s*$', '\1', '')

    if get(a:options, 'open_in') is# 'quickfix'
        return {
        \ 'filename': a:response_item.file,
        \ 'lnum': a:response_item.start.line,
        \ 'col': a:response_item.start.offset,
        \ 'text': l:match,
        \}
    else
        return {
        \ 'filename': a:response_item.file,
        \ 'line': a:response_item.start.line,
        \ 'column': a:response_item.start.offset,
        \ 'match': l:match,
        \}
    endif
endfunction

function! ale#references#HandleTSServerResponse(conn_id, response) abort
    if get(a:response, 'command', '') is# 'references'
    \&& has_key(s:references_map, a:response.request_seq)
        let l:options = remove(s:references_map, a:response.request_seq)

        if get(a:response, 'success', v:false) is v:true
            let l:item_list = []

            for l:response_item in a:response.body.refs
                call add(
                \ l:item_list,
                \ ale#references#FormatTSResponseItem(l:response_item, l:options)
                \)
            endfor

            if empty(l:item_list)
                call ale#util#Execute('echom ''No references found.''')
            else
                if get(l:options, 'open_in') is# 'quickfix'
                    call setqflist([], 'r')
                    call setqflist(l:item_list, 'a')
                    call ale#util#Execute('cc 1')
                else
                    call ale#preview#ShowSelection(l:item_list, l:options)
                endif
            endif
        endif
    endif
endfunction

function! ale#references#FormatLSPResponseItem(response_item, options) abort
    let l:line_text = ''

    let l:line= a:response_item.range.start.line
    let l:col = a:response_item.range.start.character
    let l:filename = ale#util#ToResource(a:response_item.uri)

    if get(a:options, 'show_contents') == 1
        try
            let l:line_text = substitute(readfile(l:filename)[l:line], '^\s*\(.\{-}\)\s*$', '\1', '')
        catch
            " This happens in tests
        endtry
    endif

    if get(a:options, 'use_fzf') == 1
        let l:filename = ale#util#ToResource(a:response_item.uri)
        let l:nline = a:response_item.range.start.line + 1
        let l:ncol = a:response_item.range.start.character + 1

        " grep-style output (filename:line:col:text) so that fzf can properly
        " show matches and previews using ':' as delimiter
        return l:filename . ':' . l:nline . ":" . l:ncol . ":" . l:line_text
    endif

    if get(a:options, 'open_in') is# 'quickfix'
        return {
        \ 'filename': l:filename,
        \ 'lnum': a:response_item.range.start.line + 1,
        \ 'col': a:response_item.range.start.character + 1,
        \ 'text': l:line_text,
        \}
    else
        return {
        \ 'filename': l:filename,
        \ 'line': l:line + 1,
        \ 'column': l:col + 1,
        \ 'match': l:line_text,
        \}
    endif
endfunction

function! ale#references#ShowInFzf(item_list, options) abort
    let name = "LSP References"
    let capname = "References"
    let items = copy(a:item_list)
    let cwd = getcwd() " no-custom-checks
    let sep = has('win32') ? '\' : '/'

    function! s:relative_paths(line) closure
        return substitute(a:line, '^' . cwd . sep, '', '')
    endfunction

    if get(a:options, 'use_relative_paths')
        let items = map(filter(items, 'len(v:val)'), 's:relative_paths(v:val)')
    endif

    let start_query = ''
    let fzf_options = {
    \ 'source':  items,
    \ 'options': ['--prompt', name.'> ', '--query', start_query,
    \             '--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
    \             '--delimiter', ':', '--preview-window', '+{2}/2']
    \}

    call add(fzf_options['options'], '--highlight-line') " this only works for more recent fzf versions (TODO: handle version check?)

    " wrap with #with_preview and #fzfwrap before adding the sinklist,
    " otherwise --expect options are not added
    let opts_with_preview = fzf#vim#with_preview(fzf_options)
    let bang = 0 " TODO: handle bang
    let wrapped = fzf#wrap(name, opts_with_preview, bang)

    call remove(wrapped, 'sink*') " remove the default sinklist to add in our custom sinklist

    function! wrapped.sinklist(lines) closure
        if len(a:lines) <2
            return
        endif
        let cmd = a:lines[0]
        function! s:references_to_qf(line) closure
            " mimics ag_to_qf in fzf.vim
            let parts = matchlist(a:line, '\(.\{-}\)\s*:\s*\(\d\+\)\%(\s*:\s*\(\d\+\)\)\?\%(\s*:\(.*\)\)\?')
            let filename = &acd ? fnamemodify(parts[1], ':p') : parts[1]
            return {'filename': filename, 'lnum': parts[2], 'col': parts[3], 'text': parts[4]}
        endfunction

        let references = map(filter(a:lines[1:], 'len(v:val)'), 's:references_to_qf(v:val)')

        if empty(references)
            return
        endif

        if get(a:options, 'open_in') is# 'quickfix'
            call setqflist([], 'r')
            call setqflist(references, 'a')
            echomsg 'a:lines[1]=' . string(a:lines[1:])
            call ale#util#Execute('cc 1')
        endif

        function! s:action(key, file)
            " copied from fzf.vim
            let default_action = {
              \ 'ctrl-t': 'tab split',
              \ 'ctrl-x': 'split',
              \ 'ctrl-v': 'vsplit' }

            let fzf_actions = get(g:, 'fzf_action', default_action)
            let Cmd = get(fzf_actions, a:key, 'edit')

            let cursor_cmd = escape("call cursor(" . a:file['lnum'] . "," . a:file['col'] . ")", ' ')
            let fullcmd = Cmd . " +" . cursor_cmd . " " . fnameescape(a:file['filename'])
            silent keepjumps keepalt execute fullcmd
        endfunction

        return map(references, 's:action(cmd, v:val)')
    endfunction

    call fzf#run(wrapped)
endfunction

function! ale#references#HandleLSPResponse(conn_id, response) abort
    if ! (has_key(a:response, 'id') && has_key(s:references_map, a:response.id))
        return
    endif

    let l:options = remove(s:references_map, a:response.id)

    " The result can be a Dictionary item, a List of the same, or null.
    let l:result = get(a:response, 'result', [])
    let l:item_list = []

    if type(l:result) is v:t_list
        for l:response_item in l:result
            call add(l:item_list,
            \ ale#references#FormatLSPResponseItem(l:response_item, l:options)
            \)
        endfor
    endif

    if empty(l:item_list)
        call ale#util#Execute('echom ''No references found.''')
    else
        if get(l:options, 'use_fzf') == 1
            if !exists('*fzf#run')
                throw "fzf#run function not found. You also need Vim plugin from the main fzf repository (i.e. junegunn/fzf *and* junegunn/fzf.vim)"
            endif

            call ale#references#ShowInFzf(l:item_list, l:options)
        elseif get(l:options, 'open_in') is# 'quickfix'
            call setqflist([], 'r')
            call setqflist(l:item_list, 'a')
            call ale#util#Execute('cc 1')
        else
            call ale#preview#ShowSelection(l:item_list, l:options)
        endif
    endif
endfunction

function! s:OnReady(line, column, options, linter, lsp_details) abort
    let l:id = a:lsp_details.connection_id

    if !ale#lsp#HasCapability(l:id, 'references')
        return
    endif

    let l:buffer = a:lsp_details.buffer

    let l:Callback = a:linter.lsp is# 'tsserver'
    \   ? function('ale#references#HandleTSServerResponse')
    \   : function('ale#references#HandleLSPResponse')

    call ale#lsp#RegisterCallback(l:id, l:Callback)

    if a:linter.lsp is# 'tsserver'
        let l:message = ale#lsp#tsserver_message#References(
        \   l:buffer,
        \   a:line,
        \   a:column
        \)
    else
        " Send a message saying the buffer has changed first, or the
        " references position probably won't make sense.
        call ale#lsp#NotifyForChanges(l:id, l:buffer)

        let l:message = ale#lsp#message#References(l:buffer, a:line, a:column)
    endif

    let l:request_id = ale#lsp#Send(l:id, l:message)

    let s:references_map[l:request_id] = {
    \ 'use_relative_paths': has_key(a:options, 'use_relative_paths') ? a:options.use_relative_paths : 0,
    \ 'open_in': get(a:options, 'open_in', 'current-buffer'),
    \ 'show_contents': a:options.show_contents,
    \ 'use_fzf': get(a:options, 'use_fzf', g:ale_references_use_fzf),
    \}
endfunction

function! ale#references#Find(...) abort
    let l:options = {}

    if len(a:000) > 0
        for l:option in a:000
            if l:option is? '-relative'
                let l:options.use_relative_paths = 1
            elseif l:option is? '-tab'
                let l:options.open_in = 'tab'
            elseif l:option is? '-split'
                let l:options.open_in = 'split'
            elseif l:option is? '-vsplit'
                let l:options.open_in = 'vsplit'
            elseif l:option is? '-quickfix'
                let l:options.open_in = 'quickfix'
            elseif l:option is? '-fzf'
                let l:options.use_fzf = 1
            endif
        endfor
    endif

    if !has_key(l:options, 'open_in')
        let l:default_navigation = ale#Var(bufnr(''), 'default_navigation')

        if index(['tab', 'split', 'vsplit'], l:default_navigation) >= 0
            let l:options.open_in = l:default_navigation
        endif
    endif

    if !has_key(l:options, 'show_contents')
        let l:options.show_contents = ale#Var(bufnr(''), 'references_show_contents')
    endif

    let l:buffer = bufnr('')
    let [l:line, l:column] = getpos('.')[1:2]
    let l:column = min([l:column, len(getline(l:line))])
    let l:Callback = function('s:OnReady', [l:line, l:column, l:options])

    for l:linter in ale#lsp_linter#GetEnabled(l:buffer)
        call ale#lsp_linter#StartLSP(l:buffer, l:linter, l:Callback)
    endfor
endfunction
