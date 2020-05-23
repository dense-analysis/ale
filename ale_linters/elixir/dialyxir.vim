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
    let l:bufname_unix = substitute(bufname(a:buffer), '\\', '/', 'g')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        " Use match() rather than == for umbrella app compatibility
        let l:match_filename_unix = substitute(l:match[1], '\\', '/', 'g')

        if match(l:bufname_unix, l:match_filename_unix . '$') >= 0
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

