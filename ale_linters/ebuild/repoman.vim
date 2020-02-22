" Author: Lucian Poston <lucianposton@pm.me>
" Description: Reports ebuild QA issues from repoman.

call ale#Set('ebuild_repoman_executable', 'repoman')
call ale#Set('ebuild_repoman_options', '-dx')
call ale#Set('ebuild_repoman_change_directory', 1)

function! ale_linters#ebuild#repoman#GetCommand(buffer) abort
    let l:options = ale#Var(a:buffer, 'ebuild_repoman_options')
    let l:cd_string = ale#Var(a:buffer, 'ebuild_repoman_change_directory')
    \   ? ale#path#BufferCdString(a:buffer)
    \   : ''

    return l:cd_string
    \   . '%e full -q'
    \   . (!empty(l:options) ? ' ' . l:options : '')
endfunction

function! ale_linters#ebuild#repoman#Handle(buffer, lines) abort
    let l:ebuild_repo_root = fnamemodify(bufname(a:buffer), ':p:h:h:h')
    let l:code_pattern = '\v^(  )(\S+) %(\[(\w+)\])?\s+(\d+)$'
    let l:loc_pattern = '\v^(   )([^:]+)%(: line:? (\d+))?%(%(:|,) (.+))?$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, [l:code_pattern, l:loc_pattern])
        if l:match[1] is# '  '
            let l:item = {}
            let l:item.code = l:match[2]

            if l:match[3] is# 'fatal'
                let l:item.type = 'E'
            else
                let l:item.type = 'W'
            endif
        elseif l:match[1] is# '   '
            let l:item.lnum = l:match[3]
            let l:item.text = l:match[4]
            let l:item.filename = l:ebuild_repo_root . '/' . l:match[2]
            let l:item.filename = ale#path#Simplify(l:item.filename)
            call add(l:output, l:item)
            let l:item = copy(l:item)
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('ebuild', {
\   'name': 'repoman',
\   'executable': {buffer -> ale#Var(buffer, 'ebuild_repoman_executable')},
\   'command': function('ale_linters#ebuild#repoman#GetCommand'),
\   'callback': 'ale_linters#ebuild#repoman#Handle',
\   'lint_file': 1,
\})
