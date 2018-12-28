" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: systemd-analyze unit for systemd files

function! ale_linters#systemd#systemd_analyze#Handle(buffer, lines) abort
   " Match lines like:
   " /home/bar/.config/systemd/user/synergys.socket:3: Unknown lvalue 'Bar' in section 'Unit'
    let l:pattern = '^\v(.+):(\d+): (.+)$'
    let l:output = []

    "Get current filename:
    let l:buff_name = expand('#' . a:buffer . ':p')

    " Extract the header line first
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[1] is? l:buff_name
            let l:item = {
                \   'lnum'    : str2nr(l:match[2]),
                \   'col'     : 1,
                \   'end_col' : len(l:match[0]),
                \   'type'    : 'E',
                \   'text'    : l:match[3]
                \}
            call add(l:output, l:item)
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('systemd', {
            \   'name': 'systemd-analyze',
            \   'executable': 'systemd-analyze',
            \   'command': 'systemd-analyze verify %s ',
            \   'output_stream': 'stderr',
            \   'callback': 'ale_linters#systemd#systemd_analyze#Handle',
            \   'lint_file': 1
            \})
