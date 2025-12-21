" Author: bretello https://github.com/bretello
" Description: Functions for integrating with fzf

" Handle references found with ALEFindReferences using fzf
function! ale#fzf#ShowReferences(item_list, options) abort
    let l:name = 'LSP References'
    let l:capname = 'References'
    let l:items = copy(a:item_list)
    let l:cwd = getcwd() " no-custom-checks
    let l:sep = has('win32') ? '\' : '/'

    function! s:relative_paths(line) closure abort
        return substitute(a:line, '^' . l:cwd . l:sep, '', '')
    endfunction

    if get(a:options, 'use_relative_paths')
        let l:items = map(filter(l:items, 'len(v:val)'), 's:relative_paths(v:val)')
    endif

    let l:start_query = ''
    let l:fzf_options = {
    \ 'source':  items,
    \ 'options': ['--prompt', l:name.'> ', '--query', l:start_query,
    \             '--multi', '--bind', 'alt-a:select-all,alt-d:deselect-all',
    \             '--delimiter', ':', '--preview-window', '+{2}/2']
    \}

    call add(l:fzf_options['options'], '--highlight-line') " this only works for more recent fzf versions (TODO: handle version check?)

    " wrap with #with_preview and #fzfwrap before adding the sinklist,
    " otherwise --expect options are not added
    let l:opts_with_preview = fzf#vim#with_preview(l:fzf_options)
    let l:bang = 0 " TODO: handle bang
    let l:wrapped = fzf#wrap(l:name, l:opts_with_preview, l:bang)

    call remove(l:wrapped, 'sink*') " remove the default sinklist to add in our custom sinklist

    function! l:wrapped.sinklist(lines) closure abort
        if len(a:lines) <2
            return
        endif

        let l:cmd = a:lines[0]

        function! s:references_to_qf(line) closure abort
            " mimics ag_to_qf in junegunn/fzf.vim
            let l:parts = matchlist(a:line, '\(.\{-}\)\s*:\s*\(\d\+\)\%(\s*:\s*\(\d\+\)\)\?\%(\s*:\(.*\)\)\?')
            let l:filename = &autochdir ? fnamemodify(l:parts[1], ':p') : l:parts[1]

            return {'filename': l:filename, 'lnum': l:parts[2], 'col': l:parts[3], 'text': l:parts[4]}
        endfunction

        let l:references = map(filter(a:lines[1:], 'len(v:val)'), 's:references_to_qf(v:val)')

        if empty(l:references)
            return
        endif

        if get(a:options, 'open_in') is# 'quickfix'
            call setqflist([], 'r')
            call setqflist(l:references, 'a')

            call ale#util#Execute('cc 1')
        endif

        function! s:action(key, file) abort
            " copied from fzf.vim
            let l:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

            let fzf_actions = get(g:, 'fzf_action', l:default_action)
            let l:Cmd = get(fzf_actions, a:key, 'edit')

            let l:cursor_cmd = escape('call cursor(' . a:file['lnum'] . ',' . a:file['col'] . ')', ' ')
            let l:fullcmd = l:Cmd . ' +' . l:cursor_cmd . ' ' . fnameescape(a:file['filename'])
            silent keepjumps keepalt execute fullcmd
        endfunction

        return map(l:references, 's:action(cmd, v:val)')
    endfunction

    call fzf#run(l:wrapped)
endfunction
