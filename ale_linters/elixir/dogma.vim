" Author: archseer - https://github.com/archSeer

function! ale_linters#elixir#dogma#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " lib/filename.ex:19:7: F: Pipe chain should start with a raw value.
    let l:pattern = '\v:(\d+):?(\d+)?: (.): (.+)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:type = l:match[3]
        let l:text = l:match[4]

        if l:type ==# 'C'
            let l:type = 'E'
        elseif l:type ==# 'R'
            let l:type = 'W'
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'type': l:type,
        \   'text': l:text,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('elixir', {
\   'name': 'dogma',
\   'executable': 'mix',
\   'command': 'mix dogma %s --format=flycheck',
\   'lint_file': 1,
\   'callback': 'ale_linters#elixir#dogma#Handle',
\})
