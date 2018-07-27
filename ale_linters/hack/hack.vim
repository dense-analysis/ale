" Author: Fred Emmott <fe@fb.com>
" Description: Hack support via `hack lsp`

call ale#Set('hack_hhclient_executable', 'hh_client')

function! ale_linters#hack#hack#GetProjectRoot(buffer) abort
    let l:hhconfig = ale#path#FindNearestFile(a:buffer, '.hhconfig')
    return !empty(l:hhconfig) ? fnamemodify(l:hhconfig, ':h') : ''
endfunction

function! ale_linters#hack#hack#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'hack_hhclient_executable')
endfunction


function! ale_linters#hack#hack#GetCommand(buffer) abort
    let l:executable = ale_linters#hack#hack#GetExecutable(a:buffer)
    return ale#Escape(l:executable).' lsp --from vim-ale'
endfunction

call ale#linter#Define('hack', {
\   'name': 'hack',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#hack#hack#GetExecutable',
\   'command_callback': 'ale_linters#hack#hack#GetCommand',
\   'project_root_callback': 'ale_linters#hack#hack#GetProjectRoot',
\})
