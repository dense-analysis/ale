" Author: Zeger Van de Vannet
" Description: Verible (verilog_lint) for verilog files

" Set this option to change verible lint options
if !exists('g:ale_verilog_verible_options')
    let g:ale_verilog_verible_options = ''
endif

function! ale_linters#verilog#verible#GetCommand(buffer) abort
    let l:filename = ale#util#Tempname() . '_verible_linted.v'
    call ale#command#ManageFile(a:buffer, l:filename)
    let l:lines = getbufline(a:buffer, 1, '$')
    call ale#util#Writefile(a:buffer, l:lines, l:filename)

    return 'verilog_lint'
    \ . ale#Var(a:buffer, 'verilog_verible_options') . ' '
    \ . ale#Escape(l:filename)
endfunction

function! ale_linters#verilog#verible#Handle(buffer, lines) abort
    let l:output = []

    let l:pattern = '\([^:]\+\):\(\d\+\):\(\d\+\): \([^(]\+\)'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let l:item = {
        \  'lnum': l:match[2],
        \  'col': l:match[3],
        \  'text': l:match[4]
        \}

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('verilog', {
\   'name': 'verible',
\   'output_stream': 'stdout',
\   'executable': 'verilog_lint',
\   'command': function('ale_linters#verilog#verible#GetCommand'),
\   'callback': 'ale_linters#verilog#verible#Handle',
\   'read_buffer': 0,
\})
