" Author: Jerko Steiner <https://github.com/jeremija>
" Description: https://github.com/saibing/bingo

call ale#Set('go_bingo_executable', 'bingo')
call ale#Set('go_bingo_options', '--mode stdio')

function! ale_linters#go#bingo#GetCommand(buffer) abort
    let l:executable = [ale#Escape(ale#Var(a:buffer, 'go_bingo_executable'))]
    let l:options = ale#Var(a:buffer, 'go_bingo_options')
    let l:options = filter(split(l:options, ' '), 'empty(v:val) != 1')
    let l:command = join(extend(l:executable, l:options), ' ')

    return l:command
endfunction

function! ale_linters#go#bingo#FindProjectRoot(buffer) abort
    return ale#path#FindNearestDirectory(a:buffer, '.git')
endfunction

call ale#linter#Define('go', {
\   'name': 'bingo',
\   'lsp': 'stdio',
\   'executable_callback': ale#VarFunc('go_bingo_executable'),
\   'command_callback': 'ale_linters#go#bingo#GetCommand',
\   'project_root_callback': 'ale_linters#go#bingo#FindProjectRoot',
\})
