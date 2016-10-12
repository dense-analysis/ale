" Author: Chris Kyrouac - https://github.com/fijshion
" Description: JSHint for Javascript files

if exists('g:loaded_ale_linters_javascript_jshint')
    finish
endif

let g:loaded_ale_linters_javascript_jshint = 1

let g:ale_javascript_jshint_executable =
\   get(g:, 'ale_javascript_jshint_executable', 'jshint')

function! ale_linters#javascript#jshint#GetCommand(buffer)
    " Set this to the location of the jshint configuration file to
    " use a fixed location for .jshintrc
    if exists('g:ale_jshint_config_loc')
        let l:jshint_config = g:ale_jshint_config_loc
    else
        " Look for the JSHint config in parent directories.
        let l:jshint_config = ale#util#FindNearestFile(a:buffer, '.jshintrc')
    endif

    let l:command = g:ale_javascript_jshint_executable . ' --reporter unix'

    if !empty(l:jshint_config)
        let l:command .= ' --config ' . fnameescape(l:jshint_config)
    endif

    let l:command .= ' -'

    return l:command
endfunction

call ale#linter#Define('javascript', {
\   'name': 'jshint',
\   'executable': g:ale_javascript_jshint_executable,
\   'command_callback': 'ale_linters#javascript#jshint#GetCommand',
\   'callback': 'ale#handlers#HandleUnixFormatAsError',
\})
