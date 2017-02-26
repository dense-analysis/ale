" Author: Sol Bekic https://github.com/s-ol
" Description: luacheck linter for lua files

let g:ale_lua_luacheck_executable =
\   get(g:, 'ale_lua_luacheck_executable', 'luacheck')

function! ale_linters#lua#luacheck#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " artal.lua:159:17: (W111) shadowing definition of loop variable 'i' on line 106
    " artal.lua:182:7: (W213) unused loop variable 'i'
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): (\([WE]\)\d\+) \(.\+\)$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)

        if len(l:match) == 0
            continue
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(l:output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('lua', {
\   'name': 'luacheck',
\   'executable': g:ale_lua_luacheck_executable,
\   'command': g:ale_lua_luacheck_executable . ' --formatter plain --codes --filename %s -',
\   'callback': 'ale_linters#lua#luacheck#Handle',
\})
