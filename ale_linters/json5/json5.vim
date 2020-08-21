" Author: Jeff Dickey (@jdxcode)
" Description: validates json5 with https://github.com/json5/json5

call ale#Set('json5_json5_executable', 'json5')
call ale#Set('json5_json5_use_global', get(g:, 'ale_use_global_executables', 0))

function! ale_linters#json5#json5#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'json5_json5', [
    \   'node_modules/.bin/json5',
    \   'node_modules/json5/lib/cli.js',
    \])
endfunction

function! ale_linters#json5#json5#RunWithVersionCheck(buffer) abort
    let l:executable = ale_linters#json5#json5#GetExecutable(a:buffer)

    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   l:executable,
    \   ale#Escape(l:executable) . ' --version',
    \   function('ale_linters#json5#json5#GetCommand'),
    \)
endfunction

function! ale_linters#json5#json5#GetCommand(buffer, version) abort
    let l:executable = ale_linters#json5#json5#GetExecutable(a:buffer)

    if !ale#semver#GTE(a:version, [2, 1, 3])
      return ''
    endif

    return ale#node#Executable(a:buffer, l:executable)
    \   . ' --validate'
endfunction

function! ale_linters#json5#json5#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " JSON5: invalid character 'o' at 6:5
    let l:pattern = '^JSON5: \(.\+\) at \(\d\+\):\(\d*\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'text': l:match[1],
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': 'E',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('json5', {
\   'name': 'json5',
\   'executable': function('ale_linters#json5#json5#GetExecutable'),
\   'output_stream': 'stderr',
\   'command': function('ale_linters#json5#json5#RunWithVersionCheck'),
\   'callback': 'ale_linters#json5#json5#Handle',
\})
