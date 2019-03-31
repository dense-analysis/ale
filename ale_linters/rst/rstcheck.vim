" Authors:
"   John Nduli https://github.com/jnduli,
"   Michael Goerz https://github.com/goerz
" Description: Rstcheck for reStructuredText files
"

call ale#Set('rst_rstcheck_options', '')
call ale#Set('rst_rstcheck_use_project_config', 1)


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

function! ale_linters#rst#rstcheck#GetCommand(buffer) abort
    let l:dir = expand('#' . a:buffer . ':p:h')
    let l:exec_args = ' ' . ale#Var(a:buffer, 'rst_rstcheck_options')
    if ale#Var(a:buffer, 'rst_rstcheck_use_project_config')
      let l:exec_args .= ' --config '. "'".l:dir."'"
    endif

    return ale#path#BufferCdString(a:buffer)
    \   . 'rstcheck'
    \   . l:exec_args
    \   . ' %t'
endfunction


call ale#linter#Define('rst', {
\   'name': 'rstcheck',
\   'executable': 'rstcheck',
\   'command': function('ale_linters#rst#rstcheck#GetCommand'),
\   'callback': 'ale_linters#rst#rstcheck#Handle',
\   'output_stream': 'both',
\})
