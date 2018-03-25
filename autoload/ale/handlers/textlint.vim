" Author: tokida https://rouger.info, Yasuhiro Kiyota <yasuhiroki.duck@gmail.com>, januswel <janus.wel.3@gmail.com>
" Description: textlint, a proofreading tool (https://textlint.github.io/)

call ale#Set('textlint_executable', 'textlint')
call ale#Set('textlint_use_global', 0)
call ale#Set('textlint_options', '')

function! ale#handlers#textlint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'textlint', [
    \   'node_modules/.bin/textlint',
    \])
endfunction

function! ale#handlers#textlint#GetConfig(buffer) abort
    return ale#path#FindNearestFile(a:buffer, '.textlintrc')
endfunction

function! ale#handlers#textlint#GetCommand(buffer) abort
    let l:executable = ale#handlers#textlint#GetExecutable(a:buffer)
    let l:config = ale#handlers#textlint#GetConfig(a:buffer)
    let l:options = ale#Var(a:buffer, 'textlint_options')

    let l:command_args = [ale#Escape(l:executable), '%s', '-f', 'json']
    if !empty(l:config)
        call add(l:command_args, '-c')
        call add(l:command_args, ale#Escape(l:config))
    endif
    if !empty(l:options)
        call add(l:command_args, l:options)
    endif

    return join(l:command_args, ' ')
endfunction

function! ale#handlers#textlint#HandleTextlintOutput(buffer, lines) abort
    let l:res = get(ale#util#FuzzyJSONDecode(a:lines, []), 0, {'messages': []})
    let l:output = []

    for l:err in l:res.messages
        call add(l:output, {
        \   'text': l:err.message,
        \   'type': 'W',
        \   'code': l:err.ruleId,
        \   'lnum': l:err.line,
        \   'col' : l:err.column
        \})
    endfor

    return l:output
endfunction
