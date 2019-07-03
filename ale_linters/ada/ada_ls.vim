" Author: Tim <tim@inept.tech>
" Description: Lint Ada files with the Ada Language Server

call ale#Set('ada_ls_executable', 'ada_language_server')

function! ada_ls#GetRootDir(buffer) abort
    let l:ada_gpr = ale#path#FindNearestFile(a:buffer, '*.gpr')

    return expand('#' . a:buffer . ':p:h')
endfunction

call ale#linter#Define('ada', {
\   'name': 'ada_ls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'ada_ls_executable')},
\   'command': '%e',
\   'project_root': function('ada_ls#GetRootDir'),
\   'initialization_options': {
\       'ada.trace.server': 'Verbose',
\       'ada.projectFile': '/home/tim/waterrower/water_rower.gpr',
\       'ada.defaultCharset': 'utf-8'
\   }
\})
