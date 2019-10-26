" Author: Johannes Wienke <languitar@semipol.de>
" Description: output handler for the vale JSON format
"
call ale#Set('vale_executable', 'vale')
call ale#Set('vale_options', '')

function! ale#handlers#vale#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'vale_executable')
endfunction

function! ale#handlers#vale#GetCommand(buffer) abort
    let l:executable = ale#handlers#vale#GetExecutable(a:buffer)
    let l:options = ale#Var(a:buffer, 'vale_options')


    return ale#Escape(l:executable)
    \ . (empty(l:options) ? '' : ' ' . l:options)
    \ . ' --output=JSON %t'
endfunction


function! ale#handlers#vale#GetType(severity) abort
    if a:severity is? 'warning'
        return 'W'
    elseif a:severity is? 'suggestion'
        return 'I'
    endif

    return 'E'
endfunction

function! ale#handlers#vale#Handle(buffer, lines) abort
    try
        let l:errors = json_decode(join(a:lines, ''))
    catch
        return []
    endtry

    if empty(l:errors)
        return []
    endif

    let l:output = []

    for l:error in l:errors[keys(l:errors)[0]]
        call add(l:output, {
        \   'lnum': l:error['Line'],
        \   'col': l:error['Span'][0],
        \   'end_col': l:error['Span'][1],
        \   'code': l:error['Check'],
        \   'text': l:error['Message'],
        \   'type': ale#handlers#vale#GetType(l:error['Severity']),
        \})
    endfor

    return l:output
endfunction

function! ale#handlers#vale#DefineLinter(filetype) abort
    call ale#linter#Define(a:filetype, {
    \   'name': 'vale',
    \   'executable': function('ale#handlers#vale#GetExecutable'),
    \   'command': function('ale#handlers#vale#GetCommand'),
    \   'callback': 'ale#handlers#vale#Handle',
    \})
endfunction
