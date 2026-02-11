" Authors:
"   John Nduli https://github.com/jnduli,
"   Michael Goerz https://github.com/goerz

call ale#Set('rst_rstcheck_executable', 'rstcheck')
call ale#Set('rst_rstcheck_options', '')

function! ale_linters#rst#rstcheck#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'rst_rstcheck_executable')
endfunction

function! ale_linters#rst#rstcheck#Handle(buffer, lines) abort
    " matches: 'bad_rst.rst:1: (SEVERE/4) Title overline & underline
    " mismatch.'
    let l:pattern = '\v^(.+):(\d*): \(([a-zA-Z]*)/\d*\) (.+)$'
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
        \   'lnum': l:match[2] + 0,
        \   'col': 0,
        \   'type': l:match[3] is# 'SEVERE' ? 'E' : 'W',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

function! ale_linters#rst#rstcheck#GetCommand(buffer, version) abort
    let l:executable = ale_linters#rst#rstcheck#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'rst_rstcheck_options')
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:exec_args = ale#Pad(l:options)

    if ale#semver#GTE(a:version, [3, 4, 0])
        let l:exec_args .= ' --config ' . ale#Escape(l:dir)
    endif

    return ale#Escape(l:executable)
    \   . l:exec_args
    \   . ' %t'
endfunction

function! ale_linters#rst#rstcheck#GetCommandWithVersionCheck(buffer) abort
    return ale#semver#RunWithVersionCheck(
    \   a:buffer,
    \   ale_linters#rst#rstcheck#GetExecutable(a:buffer),
    \   '%e --version',
    \   function('ale_linters#rst#rstcheck#GetCommand')
    \)
endfunction

call ale#linter#Define('rst', {
\   'name': 'rstcheck',
\   'executable': 'rstcheck',
\   'cwd': '%s:h',
\   'command': function('ale_linters#rst#rstcheck#GetCommandWithVersionCheck'),
\   'callback': 'ale_linters#rst#rstcheck#Handle',
\   'output_stream': 'both',
\})
