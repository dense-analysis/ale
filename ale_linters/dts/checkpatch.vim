" Author: Markus Schneider-Pargmann <dev@markussp.com>
" Description: checkpatch.pl checker for Kernel Files

call ale#Set('dts_checkpatch_executable', 'scripts/checkpatch.pl')
call ale#Set('dts_checkpatch_options', '--strict')

function! ale_linters#dts#checkpatch#GetCommand(buffer) abort
    return '%e --no-summary --no-tree --terse '
    \   . ale#Pad(ale#Var(a:buffer, 'dts_checkpatch_options'))
    \   . ' --file %s'
endfunction

call ale#linter#Define('dts', {
\   'name': 'checkpatch',
\   'output_stream': 'both',
\   'executable': {b -> ale#Var(b, 'dts_checkpatch_executable')},
\   'cwd': function('ale#handlers#cppcheck#GetCwd'),
\   'command': function('ale_linters#dts#checkpatch#GetCommand'),
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
