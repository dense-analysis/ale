" Author: Markus Schneider-Pargmann <dev@markussp.com>
" Description: checkpatch.pl checker for Kernel Files

call ale#Set('c_checkpatch_executable', 'scripts/checkpatch.pl')
call ale#Set('c_checkpatch_options', '--strict')

function! ale_linters#c#checkpatch#GetCommand(buffer) abort
    return '%e --no-summary --no-tree --terse '
    \   . ale#Pad(ale#Var(a:buffer, 'c_checkpatch_options'))
    \   . ' --file %s'
endfunction

call ale#linter#Define('c', {
\   'name': 'checkpatch',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'c_checkpatch_executable')},
\   'cwd': function('ale#handlers#cppcheck#GetCwd'),
\   'command': function('ale_linters#c#checkpatch#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
