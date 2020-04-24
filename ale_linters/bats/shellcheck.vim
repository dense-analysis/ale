" Author: Ian2020 <https://github.com/Ian2020>
" Description: This file adds support for using the shellcheck linter with
"   bats scripts. Heavily inspired by/copied from work by w0rp on shellcheck
"   for sh files.

" This global variable can be set with a string of comma-separated error
" codes to exclude from shellcheck. For example:
"
" let g:ale_bats_shellcheck_exclusions = 'SC2002,SC2004'
call ale#Set('bats_shellcheck_exclusions', get(g:, 'ale_linters_bats_shellcheck_exclusions', ''))
call ale#Set('bats_shellcheck_executable', 'shellcheck')
call ale#Set('bats_shellcheck_options', '')
call ale#Set('bats_shellcheck_change_directory', 1)

function! ale_linters#bats#shellcheck#GetCommand(buffer, version) abort
    let l:options = ale#Var(a:buffer, 'bats_shellcheck_options')
    let l:exclude_option = ale#Var(a:buffer, 'bats_shellcheck_exclusions')
    let l:external_option = ale#semver#GTE(a:version, [0, 4, 0]) ? ' -x' : ''
    let l:cd_string = ale#Var(a:buffer, 'bats_shellcheck_change_directory')
    \   ? ale#path#BufferCdString(a:buffer)
    \   : ''

    return l:cd_string
    \   . '%e'
    \   . ' -s bats'
    \   . (!empty(l:options) ? ' ' . l:options : '')
    \   . (!empty(l:exclude_option) ? ' -e ' . l:exclude_option : '')
    \   . l:external_option
    \   . ' -f gcc -'
endfunction

function! ale_linters#bats#shellcheck#Handle(buffer, lines) abort
    let l:pattern = '\v^([a-zA-Z]?:?[^:]+):(\d+):(\d+)?:? ([^:]+): (.+) \[([^\]]+)\]$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if l:match[4] is# 'error'
            let l:type = 'E'
        elseif l:match[4] is# 'note'
            let l:type = 'I'
        else
            let l:type = 'W'
        endif

        let l:item = {
        \   'lnum': str2nr(l:match[2]),
        \   'type': l:type,
        \   'text': l:match[5],
        \   'code': l:match[6],
        \}

        if !empty(l:match[3])
            let l:item.col = str2nr(l:match[3])
        endif

        " If the filename is something like <stdin>, <nofile> or -, then
        " this is an error for the file we checked.
        if l:match[1] isnot# '-' && l:match[1][0] isnot# '<'
            let l:item['filename'] = l:match[1]
        endif

        call add(l:output, l:item)
    endfor

    return l:output
endfunction

call ale#linter#Define('bats', {
\   'name': 'shellcheck',
\   'executable': {buffer -> ale#Var(buffer, 'bats_shellcheck_executable')},
\   'command': {buffer -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale#Var(buffer, 'bats_shellcheck_executable'),
\       '%e --version',
\       function('ale_linters#bats#shellcheck#GetCommand'),
\   )},
\   'callback': 'ale_linters#bats#shellcheck#Handle',
\})
