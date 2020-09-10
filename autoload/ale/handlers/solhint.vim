" Author: Henrique Barcelos <@hbarcelos>
" Description: Functions for working with local solhint for checking *.sol files.

let s:executables = [
\   'node_modules/.bin/solhint',
\   'node_modules/solhint/solhint.js',
\   'solhint',
\]

let s:sep = has('win32') ? '\' : '/'

call ale#Set('solidity_solhint_options', '')
call ale#Set('solidity_solhint_executable', 'solhint')
call ale#Set('solidity_solhint_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale#handlers#solhint#FindConfig(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        for l:basename in [
        \   '.solhintrc.js',
        \   '.solhintrc.json',
        \   '.solhintrc',
        \]
            let l:config = ale#path#Simplify(join([l:path, l:basename], s:sep))

            if filereadable(l:config)
                return l:config
            endif
        endfor
    endfor

    return ale#path#FindNearestFile(a:buffer, 'package.json')
endfunction

function! ale#handlers#solhint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'solidity_solhint', s:executables)
endfunction

" Given a buffer, return a command prefix string which changes directory
" as necessary for running solhint.
function! ale#handlers#solhint#GetCdString(buffer) abort
    " If solhint is installed in a directory which contains the buffer, assume
    " it is the solhint project root. Otherwise, use nearest node_modules.
    " Note: If node_modules not present yet, can't load local deps anyway.
    let l:executable = ale#node#FindNearestExecutable(a:buffer, s:executables)

    if !empty(l:executable)
        let l:nmi = strridx(l:executable, 'node_modules')
        let l:project_dir = l:executable[0:l:nmi - 2]
    else
        let l:modules_dir = ale#path#FindNearestDirectory(a:buffer, 'node_modules')
        let l:project_dir = !empty(l:modules_dir) ? fnamemodify(l:modules_dir, ':h:h') : ''
    endif

    return !empty(l:project_dir) ? ale#path#CdString(l:project_dir) : ''
endfunction

function! ale#handlers#solhint#GetCommand(buffer) abort
    let l:executable = ale#handlers#solhint#GetExecutable(a:buffer)

    let l:options = ale#Var(a:buffer, 'solidity_solhint_options')

    return ale#handlers#solhint#GetCdString(a:buffer)
    \   . ale#node#Executable(a:buffer, l:executable)
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . ' --formatter compact %s'
endfunction
