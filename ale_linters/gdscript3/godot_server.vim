" Author: Rafael Delboni
" Description: Linting for gdscript3 using godot_server

call ale#Set('gdscript3_godot_server_executable', 'godot_server')

function! s:CleanupMergeResult(lines) abort
    let l:output = []

    if len(a:lines) < 2
        return l:output
    endif

    for l:line in a:lines
        call add(l:output, substitute(l:line, '\e\[[0-9;]\+[mK]', '', 'g'))
    endfor

    return join([l:output[0], l:output[1]], ';')
endfunction

function! ale_linters#gdscript3#godot_server#Handle(buffer, lines) abort
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p:t')
    let l:pattern = '\v[a-zA-Z]?:\s(.*);\s.*At:\s(.*):(\d+)'
    let l:output = []
    let l:result_lines = s:CleanupMergeResult(a:lines)

    for l:match in ale#util#GetMatches(l:result_lines, l:pattern)
        " Only show errors of the current buffer
        let l:temp_buffer_filename = substitute(fnamemodify(l:match[2], ':p:t'), 'res://', '', 'g')

        if l:buffer_filename isnot# '' && l:temp_buffer_filename isnot# l:buffer_filename
            continue
        endif

        execute 'echo l:temp_buffer_filename'

        let l:item = {
        \   'lnum': l:match[3] + 0,
        \   'col': 1,
        \   'text': l:match[1],
        \   'type': 'E',
        \}

        call add(l:output, l:item)
    endfor

    return l:output
endfunction


function! ale_linters#gdscript3#godot_server#GetCommand(buffer) abort
    let l:executable = ale#Var(a:buffer, 'gdscript3_godot_server_executable')

    return l:executable . ' --check-only -s %s'
endfunction


call ale#linter#Define('gdscript3', {
\    'name': 'godot_server',
\    'executable': {b -> ale#Var(b, 'gdscript3_godot_server_executable')},
\    'output_stream': 'both',
\    'command': function('ale_linters#gdscript3#godot_server#GetCommand'),
\    'callback': 'ale_linters#gdscript3#godot_server#Handle',
\    'lint_file': 1,
\})
