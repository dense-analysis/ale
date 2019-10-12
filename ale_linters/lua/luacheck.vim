" Author: Sol Bekic https://github.com/s-ol
" Description: luacheck linter for lua files

call ale#Set('lua_luacheck_executable', 'luacheck')
call ale#Set('lua_luacheck_options', '')
call ale#Set('lua_luacheck_lint_project', 1)
call ale#Set('lua_luacheck_change_directory', 1)

function! ale_linters#lua#luacheck#GetCommand(buffer) abort
    let l:luacheckrc = ale#path#FindNearestFile(a:buffer, '.luacheckrc')

    let l:target = !ale#Var(a:buffer, 'lua_luacheck_lint_project') ? '--filename %s -'
    \ : !empty(l:luacheckrc)
    \ ? fnamemodify(l:luacheckrc, ':p:h')
    \ : '%s' 
    let l:cd_string = !empty(l:luacheckrc) && ale#Var(a:buffer, 'lua_luacheck_change_directory')
    \   ? ale#path#CdString(fnamemodify(l:luacheckrc, ':p:h'))
    \   : ''

    return l:cd_string . '%e' . ale#Pad(ale#Var(a:buffer, 'lua_luacheck_options'))
    \   . ' --formatter plain --codes --ranges ' . l:target
endfunction

function! ale_linters#lua#luacheck#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " artal.lua:159:17-17: (W111) shadowing definition of loop variable 'i' on line 106
    " artal.lua:182:7-7: (W213) unused loop variable 'i'
    let l:pattern = '\v^(.*):(\d+):(\d+)-(\d+): \(([WE])(\d+)\) (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
        \   && l:match[5] is# 'W'
        \   && index(range(611, 614), str2nr(l:match[6])) >= 0
            continue
        endif

        call add(l:output, {
        \   'filename': l:match[1],
        \   'lnum': l:match[2],
        \   'col': l:match[3],
        \   'end_col': l:match[4],
        \   'type': l:match[5],
        \   'code': l:match[5] . l:match[6],
        \   'text': l:match[7],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('lua', {
\   'name': 'luacheck',
\   'executable': {b -> ale#Var(b, 'lua_luacheck_executable')},
\   'command': function('ale_linters#lua#luacheck#GetCommand'),
\   'callback': 'ale_linters#lua#luacheck#Handle',
\   'lint_file': g:ale_lua_luacheck_lint_project,
\})
