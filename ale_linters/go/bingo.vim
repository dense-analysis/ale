" Author: Jerko Steiner <https://github.com/jeremija>
" Description: https://github.com/saibing/bingo

call ale#Set('go_bingo_executable', 'bingo')
call ale#Set('go_bingo_options', '--mode stdio')

function! ale_linters#go#bingo#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'go_bingo_options'))
endfunction

function! ale_linters#go#bingo#FindProjectRoot(buffer) abort
    let l:project_root = ale#path#FindNearestFile(a:buffer, 'go.mod')
    let l:mods = ':h'

    if empty(l:project_root)
        let l:project_root = ale#path#FindNearestDirectory(a:buffer, '.git')
        let l:mods = ':h:h'
    endif

    if empty(l:project_root)
	let l:project_root = ale#path#FindNearestFile(a:buffer,'main.go')
	let l:mods = ':h'
    endif

    if empty(l:project_root)
	let l:project_root = fnamemodify(bufname(a:buffer),':p')
	let l:project_root = fnameescape(l:project_root)
	let l:mods = ':h'
    else
        if empty($GOPATH) || stridx(l:project_root,$GOPATH)==-1
	    let l:project_root = fnamemodify(bufname(a:buffer),':p')
	    let l:project_root = fnameescape(l:project_root)
	    let l:mods = ':h'
        endif
    endif

    return fnamemodify(l:project_root, l:mods) 
endfunction

call ale#linter#Define('go', {
\   'name': 'bingo',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'go_bingo_executable')},
\   'command': function('ale_linters#go#bingo#GetCommand'),
\   'project_root': function('ale_linters#go#bingo#FindProjectRoot'),
\})
