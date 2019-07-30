" Author: Tim Lagnese <tim@inept.tech>
" Description: Lint Ada files with GPRBuild

call ale#Set('ada_gprbuild_executable', 'gprbuild')
call ale#Set('ada_gprbuild_options', '-gnatwa -gnatq')
call ale#Set('ada_gprbuild_project', 'default.gpr')

function! ale_linters#ada#gprbuild#GetCommand(buffer) abort
    let l:tmp_dir = fnamemodify(ale#command#CreateDirectory(a:buffer), ':p')
    let l:out_file = l:tmp_dir . fnamemodify(bufname(a:buffer), ':t:r') . '.o'
    " Build a suitable output file name. The output file is specified because
    " the .ali file may be created even if no code generation is attempted.
    " The output file name must match the source file name (except for the
    " extension), so here we cannot use the null file as output.

    " -gnatef: Full source path in brief error messages
    " -gnatc: Check syntax and semantics only (no code generation)
    return '%e'
    \   . ale#Pad(ale#Var(a:buffer, 'ada_gprbuild_project'))
    \   . ale#Pad(ale#Var(a:buffer, 'ada_gprbuild_options'))
    \   . ' -c -gnatc -gnatef %s'
endfunction

" For the message format please refer to:
"   https://gcc.gnu.org/onlinedocs/gnat_ugn/Output-and-Error-Message-Control.html
"   https://gcc.gnu.org/onlinedocs/gnat_ugn/Warning-Message-Control.html
function! ale_linters#ada#gprbuild#Handle(buffer, lines) abort
    " Error format: <filename>:<lnum>:<col>: <text>
    " Warning format: <filename>:<lnum>:<col>: warning: <text>
    let l:re = '\v(.+):([0-9]+):([0-9]+):\s+(warning:)?\s*(.+)\s*'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:re)
        call add(l:output, {
        \   'lnum': str2nr(l:match[2]),
        \   'col': str2nr(l:match[3]),
        \   'filename': l:match[1],
        \   'type': l:match[4] is# 'warning:' ? 'W' : 'E',
        \   'text': l:match[5],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('ada', {
\   'name': 'gprbuild',
\   'output_stream': 'stderr',
\   'executable': {b -> ale#Var(b, 'ada_gprbuild_executable')},
\   'command': function('ale_linters#ada#gprbuild#GetCommand'),
\   'callback': 'ale_linters#ada#gprbuild#Handle',
\})
