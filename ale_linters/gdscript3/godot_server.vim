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

function! s:ParseFilenameFromMatch(match) abort
    return substitute(fnamemodify(a:match[2], ':p:t'), 'res://', '', 'g')
endfunction

function! s:GetCurrentBufferMatches(buffer_filename, result_lines, pattern) abort
    let l:output = []

    for l:match in ale#util#GetMatches(a:result_lines, a:pattern)
        " Only show errors of the current buffer
        let l:parsed_match_filename = s:ParseFilenameFromMatch(l:match)

        if a:buffer_filename isnot# '' && l:parsed_match_filename isnot# a:buffer_filename
            continue
        endif

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

function! ale_linters#gdscript3#godot_server#Handle(buffer, lines) abort
    execute 'echo a:buffer'
    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p:t')
    let l:result_lines = s:CleanupMergeResult(a:lines)
    let l:pattern = '\v[a-zA-Z]?:\s(.*);\s.*At:\s(.*):(\d+)'

    return s:GetCurrentBufferMatches(l:buffer_filename, l:result_lines, l:pattern)
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
