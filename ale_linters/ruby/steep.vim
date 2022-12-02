call ale#Set('ruby_steep_executable', 'steep')
call ale#Set('ruby_steep_options', '')

function! ale_linters#ruby#steep#GetCommand(buffer) abort
    return '%e langserver --log-level=debug'
endfunction

call ale#linter#Define('ruby', {
\   'name': 'steep',
\   'lsp': 'stdio',
\   'language': 'ruby',
\   'executable': {b -> ale#Var(b, 'ruby_steep_executable')},
\   'command': function('ale_linters#ruby#steep#GetCommand'),
\   'project_root': function('ale#ruby#FindProjectRoot'),
\   'initialization_options': {b -> ale#Var(b, 'ruby_steep_options')},
\})


