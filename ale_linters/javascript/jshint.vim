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

function! ale_linters#javascript#jshint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " stdin:57:9: Missing name in function declaration.
    " stdin:60:5: Attempting to override 'test2' which is a constant.
    " stdin:57:10: 'test' is defined but never used.
    " stdin:57:1: 'function' is defined but never used.
    let l:pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        let l:text = l:match[3]
        let l:marker_parts = l:match[4]

        if len(l:marker_parts) == 2
            let l:text = l:text . ' (' . l:marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': l:text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('javascript', 'javascript.jsx', {
\   'name': 'jshint',
\   'executable': g:ale_javascript_jshint_executable,
\   'command_callback': 'ale_linters#javascript#jshint#GetCommand',
\   'callback': 'ale_linters#javascript#jshint#Handle',
\})
