" Author: Chris Kyrouac - https://github.com/fijshion
" Description: JSHint for Javascript files

if exists('g:loaded_ale_linters_javascript_jshint')
    finish
endif

let g:loaded_ale_linters_javascript_jshint = 1

function! ale_linters#javascript#jshint#GetCommand(buffer)
    " Set this to the location of the jshint configuration file to
    " use a fixed location for .jshintrc
    if exists('g:ale_jshint_config_loc')
        let jshint_config = g:ale_jshint_config_loc
    else
        " Look for the JSHint config in parent directories.
        let jshint_config = ale#util#FindNearestFile(a:buffer, '.jshintrc')
    endif

    let command = 'jshint --reporter unix'

    if !empty(jshint_config)
        let command .= ' --config ' . fnameescape(jshint_config)
    endif

    let command .= ' -'

    return command
endfunction

function! ale_linters#javascript#jshint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " stdin:57:9: Missing name in function declaration.
    " stdin:60:5: Attempting to override 'test2' which is a constant.
    " stdin:57:10: 'test' is defined but never used.
    " stdin:57:1: 'function' is defined but never used.
    let pattern = '^.\+:\(\d\+\):\(\d\+\): \(.\+\)'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]
        let marker_parts = l:match[4]

        if len(marker_parts) == 2
            let text = text . ' (' . marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ale#linter#Define('javascript', {
\   'name': 'jshint',
\   'executable': 'jshint',
\   'command_callback': 'ale_linters#javascript#jshint#GetCommand',
\   'callback': 'ale_linters#javascript#jshint#Handle',
\})

call ale#linter#Define('javascript.jsx', {
\   'name': 'jshint',
\   'executable': 'jshint',
\   'command_callback': 'ale_linters#javascript#jshint#GetCommand',
\   'callback': 'ale_linters#javascript#jshint#Handle',
\})
