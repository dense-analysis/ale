" Author: alihsaas (https://github.com/alihsaas)
" Description: selene linter for lua files

call ale#Set('lua_selene_executable','selene')
call ale#Set('lua_selene_options','')

function! ale_linters#lua#selene#GetCommand(buffer) abort
    return '%e'.ale#Pad(ale#Var(a:buffer,'lua_selene_options'))
                \.' --display-style=quiet %s'
endfunction

function! ale_linters#lua#selene#Handle(buffer, lines) abort
    let l:output = []
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(warning\|error\)[\(.*\)\]: \(.*\)$'

    for l:line in a:lines
        for l:match in ale#util#GetMatches(l:line, l:pattern)
            call add(l:output,{
                    \'lnum':l:match[1],
                    \'col':l:match[2],
                    \'type':toupper(l:match[3][0]),
                    \'code':l:match[4],
                    \'text':l:match[5]
                    \})
        endfor
    endfor

    return l:output
endfunction

call ale#linter#Define('lua',{
    \ 'name':'selene',
    \ 'executable': {b -> ale#Var(b,'lua_selene_executable')},
    \ 'command': function('ale_linters#lua#selene#GetCommand'),
    \ 'callback':'ale_linters#lua#selene#Handle'})
