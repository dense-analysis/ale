" Author: Fred Emmott <fe@fb.com>
" Description: Hack support via `hhast lsp`

call ale#Set('hack_hhast_executable', 'vendor/bin/hhast-lint')

function! ale_linters#hack#hhast#GetProjectRoot(buffer) abort
    let l:root = ale_linters#hack#hack#GetProjectRoot(a:buffer)
    if empty(l:root)
      return ''
    endif
    let l:hhast_config = findfile('hhast-lint.json', l:root)
    return !empty(l:hhast_config) ? l:root : ''
endfunction

function! ale_linters#hack#hhast#GetExecutable(buffer) abort
    let l:root = ale_linters#hack#hhast#GetProjectRoot(a:buffer)
    let l:relative = ale#Var(a:buffer, 'hack_hhast_executable')
    let l:absolute = findfile(l:relative, l:root)
    return !empty(l:absolute) ? l:absolute : ''
endfunction


function! ale_linters#hack#hhast#GetCommand(buffer) abort
    let l:executable = ale_linters#hack#hhast#GetExecutable(a:buffer)
    return ale#Escape(l:executable).' --mode lsp --from vim-ale'
endfunction

call ale#linter#Define('hack', {
\   'name': 'hhast',
\   'lsp': 'stdio',
\   'executable_callback': 'ale_linters#hack#hhast#GetExecutable',
\   'command_callback': 'ale_linters#hack#hhast#GetCommand',
\   'project_root_callback': 'ale_linters#hack#hhast#GetProjectRoot',
\})
