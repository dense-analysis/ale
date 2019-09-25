" Author: Masashi Iizuka <liquidz.uo@gmail.com>
" Description: linter for clojure using clj-kondo https://github.com/borkdude/clj-kondo

function! ale_linters#clojure#clj_kondo#GetCommand(buffer) abort
    let l:conf_dir = ale#path#FindNearestDirectory(a:buffer, '.clj-kondo')
    let l:conf_option = empty(l:conf_dir)
    \   ? ''
    \   : '--config ' . l:conf_dir . 'config.edn'

    return 'clj-kondo ' . l:conf_option . ' --lint %t'
endfunction

function! ale_linters#clojure#clj_kondo#HandleCljKondoFormat(buffer, lines) abort
    " output format
    " <filename>:<line>:<column>: <issue type>: <message>
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):(\d+):? ((Exception|error|warning): ?(.+))$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:type = 'E'

        if l:match[4] is? 'warning'
            let l:type = 'W'
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \   'type': l:type,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('clojure', {
\   'name': 'clj-kondo',
\   'output_stream': 'stdout',
\   'executable': 'clj-kondo',
\   'command': function('ale_linters#clojure#clj_kondo#GetCommand'),
\   'callback': 'ale_linters#clojure#clj_kondo#HandleCljKondoFormat',
\})
