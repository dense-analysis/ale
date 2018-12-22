" Author: Vincent (wahrwolf [ät] wolfpit.net)
" Description: systemd-analyze unit for systemd files

function! ale_linters#systemd#systemd_analyze#Handle(buffer, lines) abort
   " Example output
   " $ systemd-analyze
   " /home/bar/.config/systemd/user/synergys.socket:3: Unknown lvalue 'Bar' in section 'Unit'
   " /home/bar/.config/systemd/user/synergys.socket:4: Unknown lvalue 'Accept' in section 'Unit'
   " Proceeding WITHOUT firewalling in effect! (This warning is only shown for the first loaded unit using IP firewalling.)
    let l:pattern = '^\v(.+):(\d+): (.+)$'
    let l:output = []

    " Extract the header line first
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:item = {
            \   'lnum'    : str2nr(l:match[2]),
            \   'col'     : 1,
            \   'end_col' : len(l:match[0]),
            \   'type'    : 'E',
            \   'text'    : l:match[3]
            \}
        call add(l:output, l:item)
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
