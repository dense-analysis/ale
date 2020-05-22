" Author: Fran C. - https://github.com/franciscoj
" Description: Add dialyzer support for elixir through dialyxir
" https://github.com/jeremyjh/dialyxir

function! ale_linters#elixir#dialyxir#Handle(buffer, lines) abort
    " Matches patterns line the following (short format):
    "
    " lib/filename.ex:19:no_return Function fname/1 has no local return
    let l:pattern = '\v(.+):(\d+):([a-z_]+) (.+)$'
    let l:output = []
    let l:type = 'W'
    let l:bufname = bufname(a:buffer)

    " mix dialyzer paths are relative to each app in an umbrella or the
    " project root in a non-umbrella app
    let l:app_root = ale#handlers#elixir#FindMixProjectRoot(a:buffer)
    let l:bufname = substitute(l:bufname, '^' . l:app_root . '/', '', '')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:bufname == l:match[1]
            call add(l:output, {
            \   'bufnr': a:buffer,
            \   'lnum': l:match[2] + 0,
            \   'col': 0,
            \   'type': l:type,
            \   'text': l:match[4] . ' (' . l:match[3] . ')',
            \})
        endif
    endfor

    return l:output
endfunction

function! ale_linters#elixir#dialyxir#GetCommand(buffer) abort
    let l:project_root = ale#handlers#elixir#FindMixUmbrellaRoot(a:buffer)

    return ale#path#CdString(l:project_root)
    \ . 'mix help dialyzer && mix dialyzer --format=short 2>&1'
endfunction

call ale#linter#Define('elixir', {
\   'name': 'dialyxir',
\   'executable': 'mix',
\   'command': function('ale_linters#elixir#dialyxir#GetCommand'),
\   'callback': 'ale_linters#elixir#dialyxir#Handle',
\})

