function! ale_linters#systemd#systemd_analyze#Handle(buffer, lines) abort
    let l:re = '\v(.+):([0-9]+): (.+)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:re)
        call add(l:output, {
        \   'lnum': str2nr(l:match[2]),
        \   'col': 1,
        \   'type': 'W',
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('systemd', {
\   'name': 'systemd_analyze',
\   'aliases': ['systemd-analyze'],
\   'executable': 'systemd-analyze',
\   'command': 'SYSTEMD_LOG_COLOR=0 %e --user verify %s',
\   'callback': 'ale_linters#systemd#systemd_analyze#Handle',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
