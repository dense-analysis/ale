" Author: w0rp <devw0rp@gmail.com>,
" Nicolas Pauss <https://github.com/nicopauss>
" Description: cython syntax checking for cython files.

call ale#Set('pyrex_cython_executable', 'cython')
call ale#Set('pyrex_cython_options', '--warning-extra --warning-errors')

function! ale_linters#pyrex#cython#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'pyrex_cython_executable')
endfunction

function! ale_linters#pyrex#cython#GetCommand(buffer) abort
    let l:local_dir = ale#Escape(fnamemodify(bufname(a:buffer), ':p:h'))

    return ale#Escape(ale_linters#pyrex#cython#GetExecutable(a:buffer))
    \   . ' --working ' . l:local_dir . ' --include-dir ' . l:local_dir
    \   . ' ' . ale#Var(a:buffer, 'pyrex_cython_options')
    \   . ' --output-file ' . g:ale#util#nul_file . ' %t'
endfunction

call ale#linter#Define('pyrex', {
\   'name': 'cython',
\   'output_stream': 'stderr',
\   'executable_callback': 'ale_linters#pyrex#cython#GetExecutable',
\   'command_callback': 'ale_linters#pyrex#cython#GetCommand',
\   'callback': 'ale#handlers#unix#HandleAsError',
\})
