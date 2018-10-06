" Author: Takuya Fujiwara <tyru.exe@gmail.com>
" Description: swipl syntax / semantic check for Prolog files

call ale#Set('prolog_swipl_executable', 'swipl')
" sandboxed(true) prohibits executing some directives such as 'initialization main'
call ale#Set('prolog_swipl_goals', 'current_prolog_flag(argv, [File]), load_files(File, [sandboxed(true)]), halt.')

function! ale_linters#prolog#swipl#GetCommand(buffer) abort
    let l:goals = ale#Var(a:buffer, 'prolog_swipl_goals')
    let l:goals = ale#Escape(l:goals =~# '^\s*$' ? 'halt' : l:goals)

    return '%e -g ' . l:goals . ' -- %s'
endfunction

function! ale_linters#prolog#swipl#Handle(buffer, lines) abort
    let l:pattern = '\v^(ERROR|Warning)+%(:\s*[^:]+:(\d+)%(:(\d+))?)?:\s*(.*)$'
    let l:output = []
    let l:i = 0

    while l:i < len(a:lines)
        let l:match = matchlist(a:lines[l:i], l:pattern)

        if empty(l:match)
            let l:i += 1
            continue
        endif

        let [l:i, l:text] = s:GetErrMsg(l:i, a:lines, l:match[4])
        let l:item = {
        \   'lnum': (l:match[2] + 0 ? l:match[2] + 0 : 1),
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': (l:match[1] is# 'ERROR' ? 'E' : 'W'),
        \}

        if !s:Ignore(l:item)
            call add(l:output, l:item)
        endif
    endwhile

    return l:output
endfunction

" This returns [<next line number>, <error message string>]
function! s:GetErrMsg(i, lines, text) abort
    if a:text !~# '^\s*$'
        return [a:i + 1, a:text]
    endif

    let l:i = a:i + 1
    let l:text = []

    while l:i < len(a:lines) && a:lines[l:i] =~# '^\s'
        call add(l:text, s:Trim(a:lines[l:i]))
        let l:i += 1
    endwhile

    return [l:i, join(l:text, '. ')]
endfunction

function! s:Trim(str) abort
    return substitute(a:str, '\v^\s+|\s+$', '', 'g')
endfunction

" Skip sandbox error which is caused by directives
" because what we want is syntactic or semantic check.
function! s:Ignore(item) abort
    return a:item.type is# 'E' &&
    \      a:item.text =~# 'No permission to call sandboxed '
endfunction

call ale#linter#Define('prolog', {
\   'name': 'swipl',
\   'output_stream': 'stderr',
\   'executable_callback': ale#VarFunc('prolog_swipl_executable'),
\   'command_callback': 'ale_linters#prolog#swipl#GetCommand',
\   'callback': 'ale_linters#prolog#swipl#Handle',
\})
