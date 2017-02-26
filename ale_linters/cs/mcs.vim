let g:ale_cs_mcs_options = get(g:, 'ale_cs_mcs_options', '')

function! ale_linters#cs#mcs#GetCommand(buffer) abort
    return 'mcs -unsafe --parse ' . g:ale_cs_mcs_options . ' %t'
endfunction

function! ale_linters#cs#mcs#Handle(buffer, lines) abort
    " Look for lines like the following.
    "
    " Tests.cs(12,29): error CSXXXX: ; expected
    let l:pattern = '^.\+.cs(\(\d\+\),\(\d\+\)): \(.\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3] . ': ' . l:match[4],
        \   'type': l:match[3] =~# '^error' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('cs',{
\   'name': 'mcs',
\   'output_stream': 'stderr',
\   'executable': 'mcs',
\   'command_callback': 'ale_linters#cs#mcs#GetCommand',
\   'callback': 'ale_linters#cs#mcs#Handle',
\})
