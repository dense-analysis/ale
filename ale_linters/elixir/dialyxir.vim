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

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        " Use match() for umbrella app compatibility
        if match(l:bufname, l:match[1] . '$')
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

    " Pipe stderr to stdout because mix dialyxer prints on stderr
    return ale#path#CdString(l:project_root)
    \ . 'mix help dialyzer && mix dialyzer --format=short 2>&1'
endfunction

call ale#linter#Define('elixir', {
\   'name': 'dialyxir',
\   'executable': 'mix',
\   'command': function('ale_linters#elixir#dialyxir#GetCommand'),
\   'callback': 'ale_linters#elixir#dialyxir#Handle',
\})

