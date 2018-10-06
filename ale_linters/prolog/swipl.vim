" Author: Takuya Fujiwara <tyru.exe@gmail.com>
" Description: swipl syntax check for Prolog files

call ale#Set('prolog_swipl_executable', 'swipl')
" Read all terms until end of file.
" If no exceptions are occurred, halt with zero status code
call ale#Set('prolog_swipl_goals', 'current_prolog_flag(argv, [File]), see(File), repeat, read_term(T, [singletons(warning), syntax_errors(fail)]), T == end_of_file, halt.')

function! ale_linters#prolog#swipl#GetCommand(buffer) abort
    let l:goals = ale#Var(a:buffer, 'prolog_swipl_goals')
    let l:goals = ale#Escape(l:goals =~# '^\s*$' ? 'halt' : l:goals)
    return '%e -g ' . l:goals . ' -- %s'
endfunction

function! ale_linters#prolog#swipl#Handle(buffer, lines) abort
    let l:pattern = '\v^(ERROR|Warning)+:\s*[^:]+:(\d+)%(:(\d+))?:\s*(.*)$'
    let l:output = []
    let l:i = 0
    while l:i < len(a:lines)
        let l:match = matchlist(a:lines[l:i], l:pattern)
        if empty(l:match)
            let l:i += 1
            continue
        endif
        if l:match[4] =~# '^\s*$' && l:i + 1 < len(a:lines)
            let l:i += 1
            let l:text = a:lines[l:i]
        else
            let l:text = l:match[4]
        endif
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:text,
        \   'type': (l:match[1] is# 'ERROR' ? 'E' : 'W'),
        \})
        let l:i += 1
    endwhile

    return l:output
endfunction

call ale#linter#Define('prolog', {
\   'name': 'swipl',
\   'output_stream': 'stderr',
\   'executable_callback': ale#VarFunc('prolog_swipl_executable'),
\   'command_callback': 'ale_linters#prolog#swipl#GetCommand',
\   'callback': 'ale_linters#prolog#swipl#Handle',
\})
